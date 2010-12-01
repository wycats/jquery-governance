class ActiveMembership < ActiveRecord::Base
  belongs_to :member

  def self.active_at(time)
    where("started_at <= ?", time).
      where("ended_at >= ? OR ended_at IS NULL", time)
  end

  def self.members_active_at(time)
    members = active_at(time).map(&:member)
    members.uniq
  end
end
