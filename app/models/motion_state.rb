# This module serves as a namespace for the classes of the objects who handle
# the state related responsabilities of a {Motion motion}.
#
# Those classes don't extend ActiveRecord::Base, they are just Plain Old Ruby
# Objects.
#
# Motion objects take care of the instanciation of those classes when its state
# changes (see {Motion#state_name=} for the details), and simply delegate the
# following messages to them: {Motion#permit?  permit?}, {Motion#update_state
# update_state}, {Motion#scheduled_update scheduled_update}, and
# {Motion#schedule_updates schedule_updates}.
module MotionState

  # Mixin for the states of the motions who are visible to the public (i.e. any
  # other person who is not an active member).
  module PubliclyViewable
    module ClassMethods
      def public?
        true
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    # Indicates whether or not a given member is allowed to see a motion.
    # @param [Member] member A member which wants to see the motion.
    # @return [true] Everyone is allowed to see a motion in a public state.
    def permit_see?(member)
      true
    end
  end

  # Mixin for the states of the motions who are visible only visible to the
  # active members.
  module ActiveMemberViewable
    module ClassMethods
      def public?
        false
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    # Indicates whether or not a given member is allowed to see a motion.
    # @param [Member] member A member which wants to see the motion.
    # @return [true, false] Only active members are allowed to see a motion which isn't visible to anyone.
    def permit_see?(member)
      member.membership_active?
    end
  end

  # Mixin for the states of the motions who don't allow seconds.
  module NoSecondable

    # Indicates whether or not a given member is allowed to second a motion.
    # @param [Member] member A member which wants to second the motion.
    # @return [false] No one is allowed to second a motion in a no secondable state.
    def permit_second?(member)
      false
    end
  end

  # Mixin for the states of the motions who don't allow objections.
  module NoObjetionable

    # Indicates whether or not a given member is allowed to object a motion.
    # @param [Member] member A member which wants to object the motion.
    # @return [false] No one is allowed to object a motion in a no objectionable state.
    def permit_object?(member)
      false
    end
  end

  # Mixin for the states of the motions who don't allow votes.
  module NoVotable

    # Indicates whether or not a given member is allowed to vote on a motion.
    # @param [Member] member A member which wants to vote on the motion.
    # @return [false] No one is allowed to vote on a motion in a no votable state.
    def permit_vote?(member)
      false
    end
  end
end
