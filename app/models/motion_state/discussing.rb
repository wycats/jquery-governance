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
    extend Open

    # Indicates whether or not a given member is allowed to object a motion.
    # @param [Member] member A member who wants to object the motion.
    # @return [true, false] Only active members can object a motion and they can do it only once.
    def permit_object?(member)
      member.membership_active? && @motion.objections.where(:member_id => member.id).blank? && !@motion.conflicts_with?(member)

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
  end
end
