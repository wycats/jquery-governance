class Motions::ObjectedToVoting
  @queue = :objected_to_voting

  def self.perform(motion_id)
    motion = Motion.find(motion_id)

    if motion.objected?
      motion.voting!
    end
  end
end
