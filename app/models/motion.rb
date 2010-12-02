class Motion < ActiveRecord::Base
  include Voting
  
  validates_inclusion_of :state, :in =>
    %w(waitingsecond waitingexpedited waitingobjection
       objected voting passed failed approved).push(nil)

  belongs_to  :member
  has_many    :events
  has_many    :motion_conflicts
  has_many    :conflicts, :through => :motion_conflicts


  # # @return [ActiveRecord::Relation] All of the votes cast on this motion
  # def votes
  #   events.votes
  # end

  # # @return [ActiveRecord::Relation] All of the seconds cast in support of this motion
  # def seconds
  #   events.seconds
  # end

  # # @return [Fixnum] Count of current yea votes
  # def yeas
  #   votes.yeas.count
  # end
  # alias :ayes :yeas

  # # @return [Fixnum] Count of current nay votes
  # def nays
  #   votes.nays.count
  # end

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
    case action
    when :vote
      member.membership_active? && voting? && !member.has_voted_on?(self) && !conflicts_with_member?(member)
    when :see
      member.membership_active? || publicly_visible?
    when :second
      member.membership_active? && member != self.member && !publicly_visible? && !member.has_seconded?(self) 
    end
  end

  # Second this Motion
  #   @param [Member] member The member who is seconding this motion
  #   @return [true, false] Whether or not the second was accepted
  # @TODO @return
  def second(member)
    seconds.create(:member => member)

    second_count = seconds.count

    if state == "waitingsecond" && second_count >= 2
      waitingobjection!
    elsif state == "waitingexpedited" && second_count >= seconds_for_expedition
      voting!
    end
  end

  # Cast a Member's Vote
  #   @param [Member] member An active member
  #   @param [true, false] value An aye or nay vote
  #   @return [true, false] Whether or not the vote was accepted
  # @TODO @return
  def vote(member, value)
    votes.create(:member => member, :value => value)
    passed! if ayes > required_votes
  end

  ##
  # States
  ##

  # @TODO - Description
  def publicly_visible?
    voting? || passed? || approved? || failed?
  end

  # @TODO - Description
  def waitingsecond!
    # enqueue a job for 48 hours
    #
    # - if in the waitingsecond state, go into the failed state
    # - otherwise, do nothing
    if update_attributes(:state => "waitingsecond")
      Resque.enqueue_at(48.hours.from_now, Motions::WaitingsecondToFailed, self.id)
    end
  end

  def waitingsecond?
    state == "waitingsecond"
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
    # - if in the waitingexpedited state, go to the failed state
    # - otherwise, do nothing
    if update_attributes(:state => "waitingexpedited")
      Resque.enqueue_at(24.hours.from_now, Motions::WaitingexpeditedToWaitingobjection, self.id)
      Resque.enqueue_at(48.hours.from_now, Motions::WaitingexpeditedToFailed, self.id)
    end
  end

  def waitingexpedited?
    state == "waitingexpedited"
  end

  # @TODO - Description
  def waitingobjection!
    # enqueue a job for 24 hours from now.
    #
    # - if in the waitingobjection state, go to the voting state
    # - if in the objected state, enqueue a job for 24 hours
    #   - at that time, go to the voting state
    if update_attributes(:state => "waitingobjection")
      Resque.enqueue_at(24.hours.from_now, Motions::WaitingobjectionToVoting, self.id)
    end
  end

  # @TODO - Description
  def waitingobjection?
    state == "waitingobjection"
  end

  # @TODO - Description
  def objected!
    update_attributes(:state => "objected")
  end

  def objected?
    state == "objected"
  end

  # @TODO - Description
  def voting!
    # enqueue a job for 48 hours for now
    #
    # - if a majority of active members did not vote yes,
    #   go to the failed state
    # - otherwise, go into the closed state
    if update_attributes(:state => "voting")
      Resque.enqueue_at(48.hours.from_now, Motions::Voting, self.id)
    end
  end

  def voting?
    state == "voting"
  end

  # @TODO - Description
  def passed!
    update_attributes(:state => "passed")
  end
  
  def passed?
    state == "passed"
  end

  # @TODO - Description
  def approved!
    votes = yeas + nays

    update_attributes(
      :state => "approved",
      :abstains => possible_votes - votes
    )
  end

  # @TODO - Description
  def approved?
    state == "approved"
  end

  # @TODO - Description
  def failed!
    update_attributes(:state => "failed")
  end

  def failed?
    state == "failed"
  end

private
  # @TODO - Description
  def possible_votes
    # TODO: Deal with conflicts of interest
    ActiveMembership.active_at(Time.now).count
  end
end
