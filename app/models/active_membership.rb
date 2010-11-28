class ActiveMembership < ActiveRecord::Base
  belongs_to :member

  def self.active_at(time)
    where("start_time <= ?", time).
      where("end_time >= ? OR end_time IS NULL", time)
  end

  def self.members_active_at(time)
    active_at(time).include(:member).map(&:member)
  end
end
