class ActiveMembership < ActiveRecord::Base
  belongs_to :member

  # Finds all active memberships for a given time
  #   @param [Date, Time, DateTime] time The Date and Time in which to search for active memberships
  #   @return [Array] The list of active memberships, which were active at a given time
  def self.active_at(time)
    where("started_at <= ?", time).
      where("ended_at >= ? OR ended_at IS NULL", time)
  end

  # Finds all members active at a given date or date+time
  #   @param [Date, Time, DateTime] time The Date and Time in which to search for active members
  #   @return [Array] A unique list of members, active at the given time
  def self.members_active_at(time)
    members = active_at(time).map(&:member)
    members.uniq
  end
end
