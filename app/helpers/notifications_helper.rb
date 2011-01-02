module NotificationsHelper
  def print_motion_outcome(motion)
    if motion.passed?
      "is now closed and have been approved."
    elsif motion.failed?
      "is now closed and did not receive enough votes for approval"
    else
      "did not receive enough support to reach a vote"
    end
  end
end
