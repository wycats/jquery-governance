class Member < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :active_memberships
  has_many :motions
  has_many :events

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
end
