module MotionState

  # Handles the responsabilities specific of a {Motion motion} in the closed
  # state.
  #
  # A closed motion can be seen by everyone, but no one can second, object or
  # vote on it.
  class Closed < Base
    include PubliclyViewable
    include NoSecondable
    include NoObjetionable
    include NoVotable

    def self.open?
      false
    end

    def setup
      notify_members_of_outcome
    end

    private

    def notify_members_of_outcome
      send_email :motion_closed
    end
  end
end
