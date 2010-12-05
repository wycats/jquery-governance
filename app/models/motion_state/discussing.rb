module MotionState
  class Discussing < Base
    include NoVotable
    include ActiveMemberViewable
    include NoSecondable

    def schedule_updates
      schedule_updates_in(24.hours, 48.hours)
    end

    def scheduled_update(time_elapsed)
      @motion.voting! if time_elapsed >= 48.hours
      @motion.voting! if !@motion.objected? && time_elapsed >= 24.hours
    end
  end
end
