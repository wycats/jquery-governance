class Motions::Voting
  @queue = :voting
 
  def self.perform(motion_id)
    motion = Motion.find(motion_id)

   unless motion.passed?  
     motion.failed!
   end
  end
end
