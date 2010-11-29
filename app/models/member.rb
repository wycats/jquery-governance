class Member < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :active_memberships

  has_many :motions
  has_many :events

  def active_at?(time)
    active_memberships.active_at(time).first
  end

  def active?
    active_at?(Time.now)
  end
end
