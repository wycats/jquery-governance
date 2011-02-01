module MotionState

  # Handles the responsabilities specific of a {Motion motion} in the voting
  # state.
  #
  # A voting motion can be seen by everyone, but no one can second or object
  # it, and only active members without conflicts can vote on it.
  class Voting < Base
    include PubliclyViewable
    include NoSecondable
    include NoObjetionable
    extend Open

    # Indicates whether or not a given member is allowed to vote on a motion.
    # @param [Member] member A member who wants to vote the motion.
    # @return [true, false] Only active members can vote only once on a motion when they don't have conflicts.
    def permit_vote?(member)
      member && member.membership_active? && !member.has_voted_on?(@motion) && !@motion.conflicts_with?(member)
    end

    # Updates the state of a motion to closed when 47 hours has been passed.
    def scheduled_update(time_elapsed)
      @motion.closed! if time_elapsed >= 48.hours
    end
  end
end
