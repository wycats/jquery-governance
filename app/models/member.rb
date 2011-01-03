class Member < ActiveRecord::Base
  include Voting

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :memberships_attributes

  has_many :memberships
  has_many :motions
  has_many :events
  has_many :member_conflicts
  has_many :conflicts, :through => :member_conflicts
  has_many :seconded_motions, :through => :events, :source => :motion, :conditions => { :events => { :event_type => 'second' } }
  has_many :objected_motions, :through => :events, :source => :motion, :conditions => { :events => { :event_type => 'objection' } }
  has_many :voted_motions,    :through => :events, :source => :motion, :conditions => { :events => { :event_type => 'vote' } }

  accepts_nested_attributes_for :memberships

  # Checks membership status at a given Date/Time
  # @param [Date, Time, DateTime] time The time for which membership status should be checked
  # @return [ActiveMemberhsip] The membership that is found to be active at the specified time
  def active_at?(time)
    memberships.active_at(time).first
  end

  # Returns the active membership status, of this member
  # @return [true, false] Whether or not member is currently active as true or false, respectively
  def membership_active?
    true unless active_at?(Time.now).nil?
  end

  # Cast a member's Vote.
  # @param [Member] member An active member.
  # @param [true, false] value An aye or nay vote, respectively.
  # @return [Event] The Event of the vote just made.
  def vote(motion, value)
    votes.create(:motion => motion, :value => value)
  end
  # Check if the member has permissions to perform the given action over the given motion or member
  # @param [Symbol] action The action the member wants to perform
  # @param [Member, Motion] motion or member The motion or member over which the member wants to perform the action
  # @return [true, false] Whether or not the member has permissions to perform the action over the motion, respectively
  def can?(action, permissible_object)
    permissible_object.permit?(action, self)
  end

  # Check if the member is allowed to perform the given action
  # @param [Symbol] action The action the member wants to perform
  # @param [Member] member The member who wants to perfrom the action
  # @return [true, false] Whether or not it permits the member to perform the action, respectively
  def permit?(action, member)
    case action
    when :destroy
      member.membership_active? && member.is_admin?
    end
  end

  # Check if Member has voted on a given motion
  # @param [Motion] motion The motion in question
  # @return [true, false] If Member has voted on a given motion
  def has_voted_on?(motion)
    votes.where(:motion_id => motion.id).present?
  end

  # Check if Member has seconded a given motion
  # @param [Motion] motion The motion in question
  # @return [true, false] If Member has seconded a given motion
  def has_seconded?(motion)
    seconds.where(:motion_id => motion.id).present?
  end

  # Check if Member has acted on a given motion in its current state
  # @param [Motion] motion The motion in question
  # @return [true, false] If Member has seconded a given motion
  def has_acted_on?(motion)
    motion.waitingsecond? && seconded_motions.scoped.include?(motion) ||
      motion.discussing? && objected_motions.scoped.include?(motion) ||
      motion.voting? && voted_motions.scoped.include?(motion)
  end

  # Return name if present, email if not
  def name_or_email
    self.name || self.email
  end
end
