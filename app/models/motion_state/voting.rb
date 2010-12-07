module MotionState
  class Voting < Base
    include PubliclyViewable
    include NoSecondable

    def permit_vote?(member)
      member.membership_active? && !member.has_voted_on?(@motion) && !@motion.conflicts_with_member?(member)
    end

    def schedule_updates
      schedule_update_in(48.hours)
    end

    def scheduled_update(time_elapsed)
      @motion.closed! if time_elapsed >= 48.hours
    end
  end
end
