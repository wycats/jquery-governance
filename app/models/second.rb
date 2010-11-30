class Second < Event
  validate    :motion_creator_cannot_second
  validates   :member_id, :uniqueness => {
                            :scope => :motion_id
                          }

private
  # Will error if the motion creator attempts to second their motion
  def motion_creator_cannot_second
    errors.add(:member, "Member cannot second a motion that they created.") if motion.member == member
  end
end
