class Motions::WaitingexpeditedToWaitingobjection
  @queue = :waitingexpedited_to_waitingobjection

  def self.perform(motion_id)
    motion = Motion.find(motion_id)

    if motion.waitingexpedited? and motions.seconds == 2
      motion.waitingobjected!
    end
  end
end
