module MotionState
  class Discussing < Base
    include NoVotable
    include ActiveMemberViewable
    include NoSecondable

    def permit_object?(member)
      member.membership_active? && @motion.objections.where(:member_id => member.id).blank?
    end

    def schedule_updates
      schedule_updates_in(24.hours, 48.hours)
    end

    def scheduled_update(time_elapsed)
      if time_elapsed >= 48.hours
        @motion.voting!
      elsif !@motion.objected? && time_elapsed >= 24.hours
        @motion.voting!
      end
    end
  end
end
