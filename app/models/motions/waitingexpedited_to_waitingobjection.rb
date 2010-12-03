class Motions::WaitingexpeditedToWaitingobjection
  @queue = :waitingexpedited_to_waitingobjection

  def self.perform(motion_id)
    motion = Motion.find(motion_id)

    if motion.waitingexpedited? and motion.seconds.count >= 2
      motion.waitingobjection!
    end
  end
end
