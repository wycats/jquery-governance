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
  end

  class WaitingExpedited
  end

  class WaitingObjection
  end

  class Objected
  end

  class Voting
  end

  class Passed
  end

  class Failed
  end

  class Approved
  end
end
