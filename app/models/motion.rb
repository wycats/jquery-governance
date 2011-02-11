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
  include ActsAsConflictable

  # This is the texticle sugar that sets up the fields that can be searched
  # by texticle
  index do
    description
    title
    rationale
  end

  MOTION_STATES = %w(waitingsecond discussing voting closed)
  ACTIONS = %w(see withdraw comment second object withdraw_objection vote)

  scope :waitingsecond, where(:state_name => 'waitingsecond')
  scope :discussing,    where(:state_name => 'discussing')
  scope :voting,        where(:state_name => 'voting')
  scope :closed,        where(:state_name => 'closed')
  scope :publicly_viewable, where(:public => true)
  scope :privately_viewable, where(:public => false)

  scope :prev_with_same_state, lambda { |id| where('id < ?', id).where(:state_name => Motion.find(id).state_name) }

  validates :title,       :presence => true
  validates :description, :presence => true
  validates :member_id,   :presence => true
  validates :state_name,  :inclusion => { :in => MOTION_STATES }

  belongs_to :member
  has_many   :events
  has_many   :taggings, :dependent => :destroy
  has_many   :tags, :through => :taggings

  after_create :waitingsecond!, :if => :waitingsecond?

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
  def can_discuss?
    seconds.count >= 2
  end

  # Check if the member is allowed to perform the given action.
  # @param [Symbol] action The action the member wants to perform.
  # @param [Member] member The member who wants to perfrom the action.
  # @return [true, false] Whether or not the member is allowed to perform the action on this motion, respectively.
  def permit?(action, member)
    if ACTIONS.include?(action.to_s)
      send("permit_#{action}?", member)
    else
      false
    end
  end

  # Check if a motion has been objected by any member.
  # @return [true, false] Whether or not the motion has received an objection.
  def objected?
    objections.count - objection_withdrawns.count > 0
  end

  def objected_by?(member)
    objections_count = objections.where(:member_id => member).count
    withdrawns_count = objection_withdrawns.where(:member_id => member).count
    objections_count - withdrawns_count > 0
  end

  def publicly_viewable?
    voting? || closed?
  end

  def tag_list
    tags.map(&:name).join(' ')
  end

  def tag_list=(tag_list='')
    self.tags = tag_list.split(' ').map do |tag_name|
      Tag.find_or_initialize_by_name(tag_name)
    end
  end

  ##
  # States
  ##

  # Check if a motion is currently waiting for seconds.
  # @return [true, false] Whether or not the motion is in the waiting for seconds state.
  def waitingsecond?
    state_name == "waitingsecond"
  end

  # Move a motion to the discussing state.
  # @return [true, false] Whether or not the motion has been moved to the discussing state.
  def discussing!
    update_attributes(:state_name => "discussing")
    send_email(:discussion_beginning)
    schedule_updates_in(24.hours, 48.hours)
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
    update_attributes(:state_name => "voting", :public => true)
    send_email(:voting_beginning)
    schedule_update_in(48.hours)
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
    send_email(:motion_closed)
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

  # Scope to limit and sort the motions in reverse cronological order.
  # @param [Fixnum] size The (max) number of motions returned.
  # @return [ActiveRecord::Relation] Motions in reverse cronological order of creation.
  def self.paginate(size=5)
    order('created_at DESC').limit(size)
  end

private

  def permit_see?(member)
    publicly_viewable? || (member && member.membership_active?)
  end

  def permit_withdraw?(member)
    !voting? && !closed? && self.member == member
  end

  def permit_comment?(member)
    !closed? && member && member.membership_active?
  end

  def permit_second?(member)
    waitingsecond? && member && member.membership_active? && self.member != member && !member.has_seconded?(self) && !conflicts_with?(self)
  end

  def permit_object?(member)
    discussing? && member && member.membership_active? && !objected_by?(member) && !conflicts_with?(member)
  end

  def permit_withdraw_objection?(member)
    discussing? && member && member.membership_active? && objected_by?(member)
  end

  def permit_vote?(member)
    voting? && member && member.membership_active? && !member.has_voted_on?(self) && !conflicts_with?(member)
  end

  # @todo Description
  def possible_votes
    # @todo Deal with conflicts of interest
    conflicted_members_count =   Member.conflicts_with(conflicts_list, :exclude => true).count
    Membership.active_at(Time.now).count - conflicted_members_count
  end

  def waitingsecond!
    send_email(:motion_created)
    schedule_update_in(48.hours)
  end

  def send_email(notification)
    ActiveMemberNotifier.deliver(notification, self)
  end

  # Schedule automatic updates needed by the state in the given elapsed time.
  #
  # This creates a background job that tries to update the motion once the
  # given amount of times has passed.
  def schedule_updates_in(*times)
    times.each { |time| ScheduledMotionUpdate.in(time, self) }
  end
  alias :schedule_update_in :schedule_updates_in
end
