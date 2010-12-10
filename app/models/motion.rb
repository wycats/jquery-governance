class Motion < ActiveRecord::Base
  include Voting

  CLOSED_STATES = %w(closed)
  OPEN_STATES   = %w(waitingsecond discussing voting)
  MOTION_STATES = OPEN_STATES + CLOSED_STATES

  HUMAN_READABLE_MOTION_STATES = {
    'waitingsecond' => 'Waiting For Seconds',
    'voting'        => 'In Voting',
    'discussing'    => 'Discussing',
    'closed'        => 'Closed'
  }

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

  after_save :schedule_updates, :if => :state_name_changed?
  after_create :schedule_updates

  after_initialize :assign_state

  attr_reader :state

  # @return [Fixnum] The number of votes required to pass this Motion
  def required_votes
    possible_votes / 2 + 1
  end

  # @return [true, false] Whether or not Motion has met its requirement for passage
  def has_met_requirement?
    yeas >= required_votes
  end

  # @return [Fixnum] The numbers of seconds required to expedite
  def seconds_for_expedition
    possible_votes / 3 + 1
  end
  alias :seconds_for_expediting :seconds_for_expedition

  # @return [true, false] Whether the required votes to expedite has been received
  def can_expedite?
    seconds.count >= seconds_for_expedition
  end

  # @return [true, false] Whether or not the required secondses have been met, and should wait on objections
  def can_wait_objection?
    seconds.count >= 2
  end

  def seconds_count
    seconds.count
  end

  # Checks to see if a member has a conflict on a motion
  #   @param [Member] member The member who is voting on this motion
  #   @return [true, false] Whether or not member has a conflict
  def conflicts_with_member?(member)
    motion_conflicts = conflicts
    member_conflicts = member.conflicts
    (member_conflicts & motion_conflicts).size > 0
  end

  # Check if the member is allowed to perform the given action
  #   @param [Symbol] action The action the member wants to perform
  #   @param [Member] member The member who wants to perfrom the action
  #   @return [true, false] Whether or not it permits the member to perform the action, respectively
  def permit?(action, member)
    state.permit?(action, member)
  end

  # Second this Motion
  #   @param [Member] member The member who is seconding this motion
  #   @return [true, false] Whether or not the second was accepted
  # @TODO @return
  def second(member)
    seconds.create(:member => member)
  end

  def object(member)
    objections.create(:member => member)
  end

  def objected?
    objections.any?
  end

  # Cast a Member's Vote
  #   @param [Member] member An active member
  #   @param [true, false] value An aye or nay vote
  #   @return [true, false] Whether or not the vote was accepted
  # @TODO @return
  def vote(member, value)
    votes.create(:member => member, :value => value)
  end

  ##
  # States
  ##

  def state_name=(state_name)
    write_attribute(:state_name, state_name)
    assign_state
  end

  def waitingsecond?
    state_name == "waitingsecond"
  end

  def discussing!
    update_attributes(:state_name => "discussing")
  end

  def discussing?
    state_name == "discussing"
  end

  # @TODO - Description
  def voting!
    update_attributes(:state_name => "voting")
  end

  def voting?
    state_name == "voting"
  end

  def seconding?
    open? and not voting?
  end

  def passed?
    voting? && has_met_requirement?
  end

  def closed!
    update_attributes(
      :state_name => "closed",
      :abstains => possible_votes - votes.count
    )
  end

  def closed?
    state_name == "closed"
  end
  alias :is_closed? :closed?

  # @return [true, false] Motion state is open for voting or not
  def open?
    !closed?
  end
  alias :is_open? :open?


  # @TODO - Description
  def approved?
    closed? && has_met_requirement?
  end

  def failed?
    closed? && !has_met_requirement?
  end

  # Sets the motion to passed, if it has met all requirements
  def update_state
    state.update
  end

  def formatted_state(format = :human)
    if format == :human
      HUMAN_READABLE_MOTION_STATES[attributes["state_name"]]
    else
      state_name
    end
  end

  def scheduled_update(time_elapsed)
    state.scheduled_update(time_elapsed)
  end

private
  # @TODO - Description
  def possible_votes
    # TODO: Deal with conflicts of interest
    ActiveMembership.active_at(Time.now).count
  end

  def schedule_updates
    state.schedule_updates
  end

  def assign_state
    if MOTION_STATES.include?(state_name)
      @state = "MotionState::#{state_name.capitalize}".constantize.new(self)
    end
  end
end
