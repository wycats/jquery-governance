module MotionState

  # Handles the responsabilities specific of a {Motion motion} in the
  # waitingsecond state.
  #
  # A waitingsecond motion can only be seen and seconded by active members, no
  # one can object or vote on it.
  class Waitingsecond < Base
    include ActiveMemberViewable
    include NoObjetionable
    include NoVotable
    extend Open

    # Indicates whether or not a given member is allowed to second a motion.
    # @param [Member] member A member who wants to second the motion.
    # @return [true, false] Only active members can second only once a motion which hasn't been created by them.
    def permit_second?(member)
      member.membership_active? && member != @motion.member && !member.has_seconded?(@motion) && !@motion.conflicts_with?(member)
    end

    # Updates the state of a motion to discussing when 48 hours has been passed
    # and, even though the motion hasn't been seconded enough to be expedited
    # (i.e. skip the discussing state), has been seconded at least twice.
    #
    # Otherwise updates its state to closed when the 48 hours pass.
    def scheduled_update(time_elapsed)

      return if time_elapsed < 48.hours

      if @motion.expedited? && @motion.can_discuss?
        @motion.discussing!
      else
        @motion.closed!
      end
    end
  end
end
