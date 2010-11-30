class Motions::WaitingsecondToFailed
  @queue = :waitingsecond_to_failed

  def self.perform(motion_id)
    motion = Motion.find(motion_id)
   
    if motion.waitingsecond?
      motion.failed! 
    end  
  end
end
