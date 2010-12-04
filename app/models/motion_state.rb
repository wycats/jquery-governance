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

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then member.membership_active?
      when :second then member.membership_active? && member != motion.member && !member.has_seconded?(motion)
      end
    end
  end

  class WaitingExpedited
    def assert_state(motion)
      motion.voting! if motion.seconds.count >= motion.seconds_for_expedition
    end

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then member.membership_active?
      when :second then member.membership_active? && member != motion.member && !member.has_seconded?(motion)
      end
    end
  end

  class WaitingObjection
    def assert_state(*) end

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then member.membership_active?
      when :second then false
      end
    end
  end

  class Objected
    def assert_state(*) end

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then member.membership_active?
      when :second then false
      end
    end
  end

  class Voting
    def assert_state(motion)
      motion.passed! if motion.has_met_requirement?
    end

    def permit?(motion, action, member)
      case action
      when :vote then member.membership_active? && !member.has_voted_on?(motion) && !motion.conflicts_with_member?(member)
      when :see then true
      when :second then false
      end
    end
  end

  class Passed
    def assert_state(*) end

    def permit?(motion, action, member)
      case action
      when :vote then member.membership_active? && !member.has_voted_on?(motion) && !motion.conflicts_with_member?(member)
      when :see then true
      when :second then false
      end
    end
  end

  class Failed
    def assert_state(*) end

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then true
      when :second then false
      end
    end
  end

  class Approved
    def assert_state(*) end

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then true
      when :second then false
      end
    end
  end
end
