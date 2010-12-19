module MotionState
  class Waitingsecond < Base
    include ActiveMemberViewable
    include NoObjetionable
    include NoVotable

    def permit_second?(member)
      member.membership_active? && member != @motion.member && !member.has_seconded?(@motion)
    end

    def schedule_updates
      schedule_update_in(48.hours)
    end

    def update
      if @motion.expedited?
        @motion.voting! if @motion.seconds_count >= @motion.seconds_for_expedition
      else
        @motion.discussing! if @motion.seconds_count >= 2
      end
    end

    def scheduled_update(time_elapsed)
      return if time_elapsed < 48.hours

      if @motion.expedited? && @motion.seconds_count >= 2
        @motion.discussing!
      else
        @motion.closed!
      end
    end
  end
end
