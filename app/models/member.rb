class Member < ActiveRecord::Base
  include Voting 
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :active_memberships
  has_many :motions
  has_many :events
  has_many :member_conflicts
  has_many :conflicts, :through => :member_conflicts

  # Checks membership status at a given Date/Time
  #   @param [Date, Time, DateTime] time The time for which membership status should be checked
  #   @return [true, false] Whether or not member was active as true or false, respectively
  def active_at?(time)
    active_memberships.active_at(time).first
  end
  
  # Returns the active membership status, of this member
  #   @return [true, false] Whether or not member is currently active as true or false, respectively
  def membership_active?
    active_at?(Time.now)
  end

  # Check if the member has permissions to perform the given action over the given motion
  #   @param [Symbol] action The action the member wants to perform
  #   @param [Motion] motion The motion over which the member wants to perform the action
  #   @return [true, false] Whether or not the member has permissions to perform the action over the motion, respectively
  def can?(action, motion)
    motion.permit?(action, self)
  end

  def has_voted_on?(motion)
    return true unless votes.where(:motion_id => motion.id).empty?
  end
  
  def has_seconded?(motion)
    return true unless seconds.where(:motion_id => motion.id).empty?
  end
end
