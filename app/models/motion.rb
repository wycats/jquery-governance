class Motion < ActiveRecord::Base
  validates_inclusion_of :state, :in =>
    %w(waitingsecond waitingexpedited waitingobjection
       objected voting passed failed approved)

  belongs_to  :member
  has_many    :events

  # @return [Fixnum] Count of current yea votes
  def yeas
    events.where(:event_type => "vote", :value => true).count
  end
  alias :ayes :yeas

  # @return [Fixnum] Count of current nay votes
  def nays
    events.where(:event_type => "vote", :value => false).count
  end

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
    possible_votes / 3
  end
  alias :seconds_for_expediting :seconds_for_expedition

  # Second this Motion
  #   @param [Member] member The member who is seconding this motion
  #   @return [true, false] Whether or not the second was accepted
  # @TODO @return
  def second(member)
    events.create(:member => member, :event_type => "second")

    second_count = seconds

    if state == "waitingsecond" && second_count >= 2
      waitingobjection!
    elsif state == "waitingexpedited" && second_count >= seconds_for_expediting
      voting!
    end
  end

  # Cast a Member's Vote
  #   @param [Member] member An active member
  #   @param [true, false] value An aye or nay vote
  #   @return [true, false] Whether or not the vote was accepted
  # @TODO @return
  def vote(member, value)
    events.create(:member => member, :event_type => "vote", :value => value)
    passed! if ayes > required_votes
  end

  ##
  # States
  ##

  # @TODO - Description
  def waitingsecond!
    # enqueue a job for 48 hours
    #
    # - if in the waitingsecond state, go into the failed state
    # - otherwise, do nothing
    update_attributes(:state => "waitingsecond")
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
    update_attributes(:state => "waitingexpedited")
  end

  # @TODO - Description
  def waitingobjection!
    # enqueue a job for 24 hours from now.
    #
    # - if in the waitingobjection state, go to the voting state
    # - if in the objected state, enqueue a job for 24 hours
    #   - at that time, go to the voting state
    update_attributes(:state => "waitingobjection")
  end

  # @TODO - Description
  def objected!
    update_attributes(:state => "objected")
  end

  # @TODO - Description
  def voting!
    # enqueue a job for 48 hours for now
    #
    # - if a majority of active members did not vote yes,
    #   go to the failed state
    # - otherwise, go into the closed state
    update_attributes(:state => "voting")
  end

  # @TODO - Description
  def passed!
    update_attributes(:state => "passed")
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
  def failed!
    update_attributes(:state => "failed")
  end

private
  # @TODO - Description
  def possible_votes
    # TODO: Deal with conflicts of interest
    ActiveMembership.active_at(Time.now).count
  end
end
