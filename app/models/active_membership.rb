class ActiveMembership < ActiveRecord::Base
  belongs_to :member

  belongs_to :qualifying_motion, :class_name => "Motion",
                                 :foreign_key => :qualifying_motion_id

  belongs_to :disqualifying_motion, :class_name => "Motion",
                                    :foreign_key => :disqualifying_motion_id

  validates :qualifying_motion, :presence => true

  # Since there needs to be a started_at time for the motion, after an active_membership is created
  # set the started_at time to the current time
  before_save do
    self.started_at = self.qualifying_motion.closed_at
  end

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

  # Returns the motion that served as the authorization for this membership 
  #   @return [Motion] The Motion that approved this membership
  def qualified_by
    qualifying_motion
  end

  # Returns the motion that served as the authorization for this membership 
  #   @return [Motion] The Motion that approved this membership
  def disqualified_by
    disqualifying_motion
  end

  # Sets the ended_at field for the active membership, provided there is a disqualifying motion
  #   @param [Time] The time at which the membership ended 
  #   @return [Time] Returns the time if successfull, or nil if disqualifying_motion isn't present. 
  def ended_at=(time)
    @ended_at = time unless @disqualifying_motion_id.nil?
  end
end
