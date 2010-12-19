module MotionState
  class Closed < Base
    include PubliclyViewable
    include NoSecondable
    include NoObjetionable
    include NoVotable
  end
end
