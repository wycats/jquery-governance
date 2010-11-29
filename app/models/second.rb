class Second < Event
  validate :motion_creator_cannot_second

private
  def motion_creator_cannot_second
    errors.add(:member, "Member cannot second a motion that they created.") if motion.member == member
  end
end
