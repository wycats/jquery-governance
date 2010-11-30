class Motions::WaitingobjectionToVoting
  @queue = :waitingobjection_to_voting

  def self.perform(motion_id)
    motion = Motion.find(motion_id) 

    if motion.waitingobjection?
      motion.voting!
    elsif motion.objected?
      Resque.enqueue_at(24.hours.from_now, Motions::ObjectedToVoting, motion_id)
    end
  end
end
