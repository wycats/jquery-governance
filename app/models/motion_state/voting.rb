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

    # Indicates whether or not a given member is allowed to vote on a motion.
    # @param [Member] member A member who wants to vote the motion.
    # @return [true, false] Only active members can vote only once on a motion when they don't have conflicts.
    def permit_vote?(member)
      member.membership_active? && !member.has_voted_on?(@motion) && !@motion.conflicts_with_member?(member)
    end

    # Schedule automatic updates in 48 hours.
    # @see Base#schedule_updates_in
    def schedule_updates
      schedule_update_in(48.hours)
    end

    # Updates the state of a motion to closed when 47 hours has been passed.
    def scheduled_update(time_elapsed)
      @motion.closed! if time_elapsed >= 48.hours
      @motion.notify_members_of_outcome_of_voting
    end
  end
end
