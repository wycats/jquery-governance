class Motion < ActiveRecord::Base
  belongs_to :member

  has_many :events

  validates_inclusion_of :state, :in =>
    %w(waitingsecond waitingexpedited waitingobjection
       objected voting passed failed approved)

  def seconds
    events.where(:type => "second").count
  end

  def ayes
    events.where(:type => "vote", :value => true).count
  end

  def nays
    events.where(:type => "vote", :value => false).count
  end

  def required_votes
    possible_votes / 2 + 1
  end

  def seconds_for_expediting
    possible_votes / 3
  end

  def second(member)
    # TODO: Members cannot second their own motions

    events.create(:member => member, :type => "second")

    second_count = seconds

    if state == "waitingsecond" && second_count >= 2
      waitingobjection!
    elsif state == "waitingexpedited" && second_count >= seconds_for_expediting
      voting!
    end
  end

  def vote(member, value)
    events.create(:member => member, :type => "vote", :value => value)
    passed! if ayes > required_votes
  end

  ##
  # States
  ##

  def waitingsecond!
    # enqueue a job for 48 hours
    #
    # - if in the waitingsecond state, go into the failed state
    # - otherwise, do nothing
    update_attributes(:state => "waitingsecond")
  end

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

  def waitingobjection!
    # enqueue a job for 24 hours from now.
    #
    # - if in the waitingobjection state, go to the voting state
    # - if in the objected state, enqueue a job for 24 hours
    #   - at that time, go to the voting state
    update_attributes(:state => "waitingobjection")
  end

  def objected!
    update_attributes(:state => "objected")
  end

  def voting!
    # enqueue a job for 48 hours for now
    #
    # - if a majority of active members did not vote yes,
    #   go to the failed state
    # - otherwise, go into the closed state
    update_attributes(:state => "voting")
  end

  def passed!
    update_attributes(:state => "passed")
  end

  def approved!
    votes = ayes + nays

    update_attributes(
      :state => "approved",
      :abstains => possible_votes - votes
    )
  end

  def failed!
    update_attributes(:state => "failed")
  end

private
  def possible_votes
    # TODO: Deal with conflicts of interest
    ActiveMembership.active_at(Time.now).count
  end
end
