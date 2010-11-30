class Event < ActiveRecord::Base
  belongs_to  :member
  belongs_to  :motion
  validates   :member_id, :uniqueness => {
                            :scope => :motion_id
                          }
  validate    :motion_creator_cannot_second,  :if => :second?
  after_save  :assert_motion_state,           :if => :vote?

  # @return [true, false] Whether or not this is a Voting Event
  def vote?
    event_type == "vote"
  end

  # @return [true, false] Whether or not this is a Seconding Event
  def second?
    event_type == "second"
  end

private
  # Will error if the motion creator attempts to second their motion
  def motion_creator_cannot_second
    errors.add(:member, "Member cannot second a motion that they created.") if motion.member == member
  end

  # Sets the motion to passed, if it has met all requirements
  def assert_motion_state
    motion.passed! if motion.has_met_requirement?
  end
end
