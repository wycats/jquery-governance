class Membership < ActiveRecord::Base
  belongs_to :member

  belongs_to :qualifying_motion, :class_name => "Motion",
                                 :foreign_key => :qualifying_motion_id

  belongs_to :disqualifying_motion, :class_name => "Motion",
                                    :foreign_key => :disqualifying_motion_id

  validates :qualifying_motion_id, :presence => true, :existence => true

  attr_accessible :qualifying_motion_id, :disqualifying_motion_id, :is_admin

  before_save :set_membership_timestamps

  # Finds all active memberships for a given time
  # @param [Date, Time, DateTime] time The Date and Time in which to search for active memberships
  # @return [Array] The list of active memberships, which were active at a given time
  def self.active_at(time)
    where("started_at <= ?", time).
      where("ended_at >= ? OR ended_at IS NULL", time)
  end

  def self.expired
    where("started_at < ?", Time.now).
      where("ended_at < ?", Time.now)
  end

  # Finds all members active at a given date or date+time
  # @param [Date, Time, DateTime] time The Date and Time in which to search for active members
  # @return [Array] A unique list of members, active at the given time
  def self.members_active_at(time)
    members = active_at(time).map(&:member)
    members.uniq
  end

  # Returns the motion that served as the authorization for this membership 
  # @return [Motion] The Motion that approved this membership
  def qualified_by
    qualifying_motion
  end

  # Returns the motion that served as the authorization for this membership 
  # @return [Motion] The Motion that approved this membership
  def disqualified_by
    disqualifying_motion
  end

  private

  def set_membership_timestamps
    self.started_at ||= self.qualifying_motion.closed_at
    self.ended_at ||= self.disqualifying_motion.closed_at unless self.disqualifying_motion.nil?
  end
end
