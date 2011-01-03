# Instances of this class are the fundamental objects of the application, so a
# careful reading of this is highly recomended.
#
#
# = Motion life cycle
#
# During its life cycle a motion goes through several states (waiting for
# seconds, discussing, voting and closed), and its behaviour is defined by each
# one of them.
#
# * Initially, when a motion is created, is <b>waiting for seconds</b>.
#   Members must second a motion in order to continue the voting process.  If a
#   motion doesn't get (at least) two seconds in 48 hours is <b>closed</b>.
#   Please note that a member can't second its own motion.
#
# * When a motion which hasn't been marked as expedited gets two seconds is
#   moved into the <b>discussing</b> state.
#
# * A motion marked as expedited that gets enough seconds to bypass the
#   <b>discussing</b> state (1/3 of the possible votes) is directly brought to
#   the <b>voting</b> state.  If it gets two o more seconds is moved into the
#   <b>discussing</b> state once 48 hours has passed since its creation.
#
# * A motion is brought to the <b>voting</b> voting state when it has been in
#   the <b>discussing</b> state for 24 hours, unless one o more members object
#   it.  In that situation, 24 additional hours will be waited before the voting
#   process starts.
#
# * A motion is automatically <b>closed</b> once it has been being voted for 48
#   hours.  A closed motion is considered either <em>approved</em> or
#   <em>failed</em> whether it got the mayority of the votes or not,
#   respectively.
#
#
# = Motion state updates
#
# The state of a motion is defined by the value of its <tt>state_name</tt>
# attribute.  Every new motion starts waiting for seconds, because is defined
# as the default value in the db.
#
# However, a motion change its state when it receives one of the following
# messages:
#
# * {#discussing!}
#
# * {#voting!}
#
# * {#closed!}
#
# There are two sources from where those messages can came from.  First, every
# time a {Event} object is created (i.e. a motion is seconded, objected, or
# voted), it will send a {#update_state} message to the motion to which it
# belongs.  Depending on the motion's current state and the rules explained
# before it might change its state.  The second source is the motion itself.
# Every time a motion state is updated, it will enqueue a Resque job
# ({ScheduledMotionUpdate}) to be excecuted sometime in the future if needed.
# This job will also try to update the motion state according to the previous
# rules.
class Motion < ActiveRecord::Base
  include Voting

  # This is the texticle sugar that sets up the fields that can be searched
  # by texticle
  index do
    description
    title
    rationale
  end

  CLOSED_STATES = %w(closed)
  OPEN_STATES   = %w(waitingsecond discussing voting)
  MOTION_STATES = OPEN_STATES + CLOSED_STATES

  scope :open_state,    where(:state_name => OPEN_STATES)
  scope :closed_state,  where(:state_name => CLOSED_STATES)
  scope :waitingsecond, where(:state_name => 'waitingsecond')
  scope :discussing,    where(:state_name => 'discussing')
  scope :voting,        where(:state_name => 'voting')

  scope :prev_with_same_state, lambda { |id| where('id < ?', id).where(:state_name => Motion.find(id).state_name) }

  validates :state_name, :inclusion => { :in => MOTION_STATES }

  belongs_to  :member
  has_many    :events
  has_many    :motion_conflicts
  has_many    :conflicts, :through => :motion_conflicts
  has_and_belongs_to_many :tags, :join_table => "taggings"

  after_save :schedule_updates, :if => :state_name_changed?
  after_create :schedule_updates

  after_initialize :assign_state

  after_save :setup_state

  attr_reader :state

  # More than the half of the possible votes are required to approve a motion.
  # @return [Fixnum] The number of votes required to approve this motion.
  def required_votes
    possible_votes / 2 + 1
  end

  # Check if a motion has enough possitive votes to be approved.
  # @return [true, false] Whether or not this motion has met its requirement for approval.
  def has_met_requirement?
    yeas >= required_votes
  end

  # More than a third of the possible votes are required to expedite a motion.
  # @return [Fixnum] The numbers of seconds required to expedite.
  def seconds_for_expedition
    possible_votes / 3 + 1
  end
  alias :seconds_for_expediting :seconds_for_expedition

  # Check if a motion has enough seconds to bypass the discussion and be
  # brought inmediately to a vote (be expedited).
  # @return [true, false] Whether the required votes to expedite has been received.
  def can_expedite?
    seconds.count >= seconds_for_expedition
  end

  # Check if a motion has enough seconds (more than two) to start being
  # discussed.
  # @return [true, false] Whether or not this motion has received enough seconds to start being discussed.
  def can_wait_objection?
    seconds.count >= 2
  end

  # @return [Fixnum] The numbers of seconds this motion has received.
  def seconds_count
    seconds.count
  end

  # Checks to see if a member has a conflict on a motion.
  # @param [Member] member The member who is voting on this motion.
  # @return [true, false] Whether or not member has a conflict.
  def conflicts_with_member?(member)
    motion_conflicts = conflicts
    member_conflicts = member.conflicts
    (member_conflicts & motion_conflicts).size > 0
  end

  # Check if the member is allowed to perform the given action.
  # @param [Symbol] action The action the member wants to perform.
  # @param [Member] member The member who wants to perfrom the action.
  # @return [true, false] Whether or not the member is allowed to perform the action on this motion, respectively.
  def permit?(action, member)
    state.permit?(action, member)
  end

  # Second a motion.
  # @param [Member] member The member who is seconding this motion.
  # @return [Event] The Event object of the second just made.
  def second(member)
    seconds.create(:member => member)
  end

  # Object a motion.
  # @param [Member] member The member who is objecting this motion.
  # @return [Event] The Event object of the objection just made.
  def object(member)
    objections.create(:member => member)
  end

  # Check if a motion has been objected by any member.
  # @return [true, false] Whether or not the motion has received an objection.
  def objected?
    objections.any?
  end


  ##
  # States
  ##

  # Updates the motion's attribute <tt>state_name</tt>, and assigns the state
  # object corresponding to the new state.
  # @note There's a convention between state names and state object classes: a state with the name 'waitingsecond' will instantiate a {MotionState::Waitingsecond} object.
  # @param [String] state_name The name of the new motion state.
  # @return [MotionState::Base, nil] The state object if it exists, nil otherwise.
  def state_name=(state_name)
    write_attribute(:state_name, state_name)
    assign_state
  end

  # Check if a motion is currently waiting for seconds.
  # @return [true, false] Whether or not the motion is in the waiting for seconds state.
  def waitingsecond?
    state_name == "waitingsecond"
  end

  # Move a motion to the discussing state.
  # @return [true, false] Whether or not the motion has been moved to the discussing state.
  def discussing!
    update_attributes(:state_name => "discussing")
  end

  # Check if a motion is currently being discussed. For the details of the
  # behaviour of a motion in this state see the corresponding MotionState
  # object.
  # @see MotionState::Discussing
  # @return [true, false] Whether or not the motion is in the discussing state.
  def discussing?
    state_name == "discussing"
  end

  # Move a motion to the voting state.
  # @return [true, false] Whether or not the motion has been moved to the voting state.
  def voting!
    update_attributes(:state_name => "voting")
  end

  # Check if a motion is currently being voted.  For the details of the
  # behaviour of a motion in this state see the corresponding MotionState
  # object.
  # @see MotionState::Voting
  # @return [true, false] Whether or not the motion is in the voting state.
  def voting?
    state_name == "voting"
  end

  # A motion is considered passed when it has enough votes to be accepted but
  # the voting period hasn't ended.
  # @return [true, false] Whether or not the motion has passed.
  def passed?
    voting? && has_met_requirement?
  end

  # Move a motion to the closed state.  Also calculates the number of members
  # who abstained from voting and record the time when the motion was closed. Also notify
  # members on the outcome of the vote. 
  # @return [true, false] Whether or not the motion has been moved to the closed state.
  def closed!
    update_attributes(
      :state_name => "closed",
      :abstains => possible_votes - votes.count,
      :closed_at => Time.now
    )
  end

  # The time when the motion was approved.
  # @return [DateTime, nil] The time when the motion was closed if it was approved, otherwise nil.
  def approved_at
    closed_at if approved?
  end

  # Check if the voting period of a motion has ended or if the motion never got
  # there.  For the details of the behaviour of a motion in this state see the
  # corresponding MotionState object.
  # @see MotionState::Closed
  # @return [true, false] Whether or not the motion is in the closed state.
  def closed?
    state_name == "closed"
  end
  alias :is_closed? :closed?

  # A open state is any state different than closed.
  # @see #closed?
  # @return [true, false] Whether or not the motion is in a open state.
  def open?
    !closed?
  end
  alias :is_open? :open?

  # A motion is considered approved when it has enough votes to be accepted and
  # the voting period has ended.
  # @return [true, false] Whether or not the motion has been approved.
  def approved?
    closed? && has_met_requirement?
  end

  # A motion is considered failed when it didn't get enough votes to be
  # accepted in the voting period, or when it didn't even got the enough
  # seconds to be there.
  # @return [true, false] Whether or not the motion has failed.
  def failed?
    closed? && !has_met_requirement?
  end

  # Try to update a motion state.  This method should be called every time a
  # new {Event} object is created.  The corresponding {MotionState::Base}
  # object knows the rules for updating the motion state.
  # @see MotionState::Base#update
  def update_state
    state.update
  end

  # Try to update a motion state.  This method should be called when a certain
  # amount of time has passed since the motion entered its current state.  The
  # corresponding {MotionState::Base} object knows the rules for updating the
  # motion state.
  # @see MotionState::Base#scheduled_update
  # @see #schedule_updates
  # @param [Fixnum] The number of seconds that has been passed since the motion entered its current state.
  def scheduled_update(time_elapsed)
    state.scheduled_update(time_elapsed)
  end

  # Scope to limit and sort the motions in reverse cronological order.
  # @param [Fixnum] size The (max) number of motions returned.
  # @return [ActiveRecord::Relation] Motions in reverse cronological order of creation.
  def self.paginate(size=5)
    order('created_at DESC').limit(size)
  end

  # Find motions that are currently being voted and already closed grouped by
  # state.
  # @param [ActiveRecord::Relation] scope The scope for every group.
  # @return [Hash] An entry for every group is in it, the key is the state name and the value are the motions.
  def self.public_groups(scope=scoped)
    { :voting => scope.voting, :closed => scope.closed_state }
  end

  # Find motions that are currently in the open states grouped by state.
  # @param [ActiveRecord::Relation] scope The scope for every group.
  # @return [Hash] An entry for every group is in it, the key is the state name and the value are the motions.
  def self.open_groups(scope=scoped)
    { :waitingsecond => scope.waitingsecond, :discussing => scope.discussing, :voting => scope.voting }
  end

  # Find motions that are currently in the closed state.
  # @param [ActiveRecord::Relation] scope The scope for the group.
  # @return [Hash] The key is the state name and the value are the motions.
  def self.closed_groups(scope=scoped)
    { :groups => { :closed => scope.closed_state }, :name => :closed }
  end

  # Return the motion groups based on the user who is requesting them
  # @param [Member] user The user who is requesting the motion groups 
  # @param [ActiveRecord::Relation] scope The scope for the group.
  # @return [Hash] :groups returns the actual groups, and :name returns the name of the group
  def self.motion_groups_for_user(user, scope=nil)
    # If there is no current user then that means that a guest is searching
    # the motions, this is an easy way to handle a guest.
    user ||= Member.new

    if user.membership_active?
      {:groups => Motion.open_groups(scope), :name => :open}
    else
      {:groups => Motion.public_groups(scope),:name => :public}
    end
  end

private
  # @todo Description
  def possible_votes
    # @todo Deal with conflicts of interest
    Membership.active_at(Time.now).count
  end

  def schedule_updates
    state.schedule_updates
  end

  def setup_state
    @state.setup
  end

  def assign_state
    if MOTION_STATES.include?(state_name)
      @state = "MotionState::#{state_name.capitalize}".constantize.new(self)
    end
  end
end
