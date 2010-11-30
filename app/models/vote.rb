class Vote < Event
  after_save  :assert_motion_state
  validates   :member_id, :uniqueness => {
                            :scope => :motion_id
                          }
  # @return [ActiveRecord::Relation] An Array-like structure, of all aye-votes cast
  def self.yeas
    where :value => true
  end

  # @return [ActiveRecord::Relation] An Array-like structure, of all nay-votes cast
  def self.nays
    where :value => false
  end

private
  # Sets the motion to passed, if it has met all requirements
  def assert_motion_state
    motion.passed! if motion.has_met_requirement?
  end
end
