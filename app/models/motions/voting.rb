class Motions::Voting
  @queue = :voting

  # @TODO - Description
  def self.perform(motion_id)
    motion = Motion.find(motion_id)

    motion.failed! unless motion.passed?
  end
end
