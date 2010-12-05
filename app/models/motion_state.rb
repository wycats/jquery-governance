module MotionState
  def self.for(state_name)
    case state_name
    when 'waitingsecond' then WaitingSecond.new
    when 'discussing' then Discussing.new
    when 'voting' then Voting.new
    when 'closed' then Closed.new
    end
  end

  class WaitingSecond
    def update(motion)
      motion.expedited? ? update_expedited(motion) : update_non_expedited(motion)
    end

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then member.membership_active?
      when :second then member.membership_active? && member != motion.member && !member.has_seconded?(motion)
      end
    end

    def scheduled_update(motion, time_elapsed)
      motion.failed! if time_elapsed >= 48.hours
    end

    def schedule_updates(motion)
      ScheduledMotionUpdate.in(48.hours, motion)
    end

  private

    def update_expedited(motion)
      motion.voting! if motion.seconds.count >= motion.seconds_for_expedition
    end

    def update_non_expedited(motion)
      motion.waitingobjection! if motion.seconds.count >= 2
    end
  end

  class Discussing
    def update(*) end

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then member.membership_active?
      when :second then false
      end
    end

    def scheduled_update(motion, time_elapsed)
      motion.voting! if time_elapsed >= 48.hours
      motion.voting! if !motion.objected? && time_elapsed >= 24.hours
    end

    def schedule_updates(motion)
      ScheduledMotionUpdate.in(24.hours, motion)
      ScheduledMotionUpdate.in(48.hours, motion)
    end
  end

  class Voting
    def update(motion)
      motion.passed! if motion.has_met_requirement?
    end

    def permit?(motion, action, member)
      case action
      when :vote then member.membership_active? && !member.has_voted_on?(motion) && !motion.conflicts_with_member?(member)
      when :see then true
      when :second then false
      end
    end

    def scheduled_update(motion, time_elapsed)
      if time_elapsed >= 24.hours
        motion.passed? ? motion.approved! : motion.failed!
      end
    end

    def schedule_updates(motion)
      ScheduledMotionUpdate.in(24.hours, motion)
    end
  end

  class Closed
    def update(*) end

    def permit?(motion, action, member)
      case action
      when :vote then false
      when :see then true
      when :second then false
      end
    end

    def scheduled_update(*) end
    def schedule_updates(*) end
  end
end
