module MotionState
  class Waitingsecond < Base
    include ActiveMemberViewable
    include NoVotable

    def permit_second?(member)
      member.membership_active? && member != @motion.member && !member.has_seconded?(@motion)
    end

    def schedule_updates
      schedule_update_in(48.hours)
    end

    def update
      @motion.expedited? ? update_expedited : update_non_expedited
    end

    def scheduled_update(time_elapsed)
      @motion.failed! if time_elapsed >= 48.hours
    end

  private

    def update_expedited
      @motion.voting! if @motion.seconds.count >= @motion.seconds_for_expedition
    end

    def update_non_expedited
      @motion.waitingobjection! if @motion.seconds.count >= 2
    end
  end
end
