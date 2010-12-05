module MotionState
  module PubliclyViewable
    def permit_see?(member)
      true
    end
  end

  module ActiveMemberViewable
    def permit_see?(member)
      member.membership_active?
    end
  end

  module NoSecondable
    def permit_second?(member)
      false
    end
  end

  module NoVotable
    def permit_vote?(member)
      false
    end
  end
end
