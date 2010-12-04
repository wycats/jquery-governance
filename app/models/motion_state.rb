module MotionState
  def self.for(state_name)
    case state_name
    when 'waitingsecond' then WaitingSecond.new
    when 'waitingexpedited' then WaitingExpedited.new
    when 'waitingobjection' then WaitingObjection.new
    when 'objected' then Objected.new
    when 'voting' then Voting.new
    when 'passed' then Passed.new
    when 'failed' then Failed.new
    when 'approved' then Approved.new
    end
  end

  class WaitingSecond
    def assert_state(motion)
      motion.waitingobjection! if motion.seconds.count >= 2
    end
  end

  class WaitingExpedited
    def assert_state(motion)
      motion.voting! if motion.seconds.count >= motion.seconds_for_expedition
    end
  end

  class WaitingObjection
    def assert_state(*) end
  end

  class Objected
    def assert_state(*) end
  end

  class Voting
    def assert_state(motion)
      motion.passed! if motion.has_met_requirement?
    end
  end

  class Passed
    def assert_state(*) end
  end

  class Failed
    def assert_state(*) end
  end

  class Approved
    def assert_state(*) end
  end
end
