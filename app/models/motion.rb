class Motion < ActiveRecord::Base
  include Voting

  validates_inclusion_of :state_name, :in =>
    %w(waitingsecond discussing
       voting passed closed).push(nil)

  belongs_to  :member
  has_many    :events
  has_many    :motion_conflicts
  has_many    :conflicts, :through => :motion_conflicts

  after_create :initialize_state

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
    state.permit?(self, action, member)
  end

  # Second this Motion
  #   @param [Member] member The member who is seconding this motion
  #   @return [true, false] Whether or not the second was accepted
  # @TODO @return
  def second(member)
    seconds.create(:member => member)
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

  # @TODO - Description
  def waitingsecond!
    # enqueue a job for 48 hours
    #
    # - if in the waitingsecond state, go into the failed state
    # - otherwise, do nothing
    update_state("waitingsecond")
  end

  def waitingsecond?
    state_name == "waitingsecond"
  end

  # @TODO - Description
  def waitingexpedited!
    # enqueue a job for 24 hours
    #
    # - if in the waitingexpedited state and there are 2
    #   seconds, go into the waitingobjection state
    # - otherwise, do nothing
    #
    # enqueue a job for 48 hours
    #
    # - if in the waitingexpedited state, go to the failed tate
    # - otherwise, do nothing
    self.expedited = true
    update_state("waitingsecond")
  end

  def waitingexpedited?
    state_name == "waitingsecond" && expedited?
  end

  # @TODO - Description
  def waitingobjection!
    # enqueue a job for 24 hours from now.
    #
    # - if in the waitingobjection state, go to the voting state
    # - if in the objected state, enqueue a job for 24 hours
    #   - at that time, go to the voting state
    update_state("discussing")
  end

  # @TODO - Description
  def waitingobjection?
    state_name == "discussing" && !objected?
  end

  # @TODO - Description
  def objected!
    # NOTE this isn't doing what is was supposed to do anymore
    update_state("discussing")
  end

  def objected?
    objections.any?
  end

  # @TODO - Description
  def voting!
    # enqueue a job for 48 hours for now
    #
    # - if a majority of active members did not vote yes,
    #   go to the failed state
    # - otherwise, go into the closed state
    update_state("voting")
  end

  def voting?
    state_name == "voting"
  end

  # @TODO - Description
  def passed!
    update_attributes(:state_name => "voting")
  end

  def passed?
    state_name == "voting" && has_met_requirement?
  end

  # @TODO - Description
  def approved!
    votes = yeas + nays

    update_attributes(
      :state_name => "closed",
      :abstains => possible_votes - votes
    )
  end

  # @TODO - Description
  def approved?
    state_name == "closed" && has_met_requirement?
  end

  # @TODO - Description
  def failed!
    update_attributes(:state_name => "closed")
  end

  def failed?
    state_name == "closed" && !has_met_requirement?
  end

  # Sets the motion to passed, if it has met all requirements
  def update_state(new_state_name=nil)
    if new_state_name.nil?
      state.update(self)
    else
      state.schedule_updates(self) if update_attributes(:state_name => new_state_name)
    end
  end

  def scheduled_update(time_elapsed)
    state.scheduled_update(self, time_elapsed)
  end

private
  # @TODO - Description
  def possible_votes
    # TODO: Deal with conflicts of interest
    ActiveMembership.active_at(Time.now).count
  end

  def initialize_state
    waitingsecond! unless state_name
  end

  def assign_state
    @state = MotionState.for(state_name)
  end
end
