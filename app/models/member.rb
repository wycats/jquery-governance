class Member < ActiveRecord::Base
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
