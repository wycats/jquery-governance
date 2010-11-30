class Motions::WaitingexpeditedToFailed
  @queue = :waitingexpedited_to_failed
 
  def self.perform(motion_id)
    motion = Motion.find(motion_id)
   
    if motion.waitingexpedited?
      motion.failed!
    end
  end
end
