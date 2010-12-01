class Event < ActiveRecord::Base
  EVENT_TYPES = ["vote", "second"]

  belongs_to  :member
  belongs_to  :motion

  validates   :member_id,   :uniqueness => {
                              :scope => :motion_id
                            }
  validates   :event_type,  :presence   => true,
                            :inclusion  => {
                              :in => EVENT_TYPES
                            }

  validate    :motion_creator_cannot_second,  :if => :is_second?
  after_save  :assert_motion_state,           :if => :is_vote?

  scope :votes,   where(:event_type  => "vote")
  scope :seconds, where(:event_type  => "second")

  # @return [true, false] Whether or not this is a Voting Event
  def is_vote?
    event_type == "vote"
  end
  alias :vote? :is_vote?

  # @return [true, false] Whether or not this is a Seconding Event
  def is_second?
    event_type == "second"
  end
  alias :second? :is_second?

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
