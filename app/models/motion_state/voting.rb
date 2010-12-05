module MotionState
  class Voting < Base
    include PubliclyViewable
    include NoSecondable

    def permit_vote?(member)
      member.membership_active? && !member.has_voted_on?(@motion) && !@motion.conflicts_with_member?(member)
    end

    def schedule_updates
      schedule_update_in(24.hours)
    end

    def update
      @motion.passed! if @motion.has_met_requirement?
    end

    def scheduled_update(time_elapsed)
      if time_elapsed >= 24.hours
        @motion.passed? ? @motion.approved! : @motion.failed!
      end
    end
  end
end
