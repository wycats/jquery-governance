module Voting
  #Since its useful to keep track of the votes of members and motions, its preferred to
  #refactor this methods into a module

  def publicly_viewable_events
    events.publicly_viewable
  end

  # @return [ActiveRecord::Relation] All of the votes cast on this motion
  def votes
    events.votes
  end

  # @return [ActiveRecord::Relation] All of the seconds cast in support of this motion
  def seconds
    events.seconds
  end

  # @return [ActiveRecord::Relation] All of the objections cast in support of this motion
  def objections
    events.objections
  end

  def objection_withdrawns
    events.objection_withdrawns
  end

  # @return [Fixnum] Count of current yea votes
  def yeas
    events.yes_votes.count
  end
  alias :ayes :yeas

  # @return [Fixnum] Count of current nay votes
  def nays
    events.no_votes.count
  end
end
