class Vote < Event
  after_save  :assert_motion_state
  validates   :member_id, :uniqueness => {
                            :scope => :motion_id
                          }

private
  # Sets the motion to passed, if it has met all requirements
  def assert_motion_state
    motion.passed! if motion.has_met_requirement?
  end
end
