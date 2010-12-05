module MotionState
  class Closed < Base
    include PubliclyViewable
    include NoSecondable
    include NoVotable
  end
end
