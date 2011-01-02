module MotionState

  # Handles the responsabilities specific of a {Motion motion} in the
  # discussing state.
  #
  # A discussing motion can only be seen and be objected by active members, no
  # one can second or vote on it.
  class Discussing < Base
    include NoVotable
    include ActiveMemberViewable
    include NoSecondable

    def setup
      notify_members_discussion_beginning
    end

    # Indicates whether or not a given member is allowed to object a motion.
    # @param [Member] member A member who wants to object the motion.
    # @return [true, false] Only active members can object a motion and they can do it only once.
    def permit_object?(member)
      member.membership_active? && @motion.objections.where(:member_id => member.id).blank?
    end

    # Schedule automatic updates in 24 and 48 hours.
    # @see Base#schedule_updates_in
    def schedule_updates
      schedule_updates_in(24.hours, 48.hours)
    end

    # Updates the state of a motion to voting when 24 hours has been passed and
    # the motion hasn't been objected, or when 48 hours has been passed.
    def scheduled_update(time_elapsed)
      if time_elapsed >= 48.hours
        @motion.voting!
      elsif !@motion.objected? && time_elapsed >= 24.hours
        @motion.voting!
      end
    end

    private

    def notify_members_discussion_beginning
      send_email :discussion_beginning
    end
  end
end
