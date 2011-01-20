module MotionState

  # @abstract Subclass and override the methods applicable to the state.
  #
  # This class has stub methods for all the messages a state object needs to
  # understand.
  class Base
    def self.public?
    end

    def self.open?
    end

    def self.closed?
      !open?
    end

    # @param [Motion] The Motion to which belongs this state.
    # @return [Base subclass] A new instance of the class that extends Base.
    def initialize(motion)
      @motion = motion
    end

    # Indicates whether or not a given is allowed to perform a given action on a member.
    # @param [Symbol, String] action The action the member wants to perform over the motion.
    # @return [true, false] Whether or not the member is allowed to perfrom the action over the motion.
    def permit?(action, member)
      method = "permit_#{action}?"
      public_send(method, member) if self.respond_to?(method)
    end

    # Indicates whether or not a given member is allowed to see a motion.
    # @param [Member] member A member which wants to see the motion.
    # @return [true, false] Whether or not the member is allowed to see the motion.
    def permit_see?(member)
    end

    # Indicates whether or not a given member is allowed to second a motion.
    # @param [Member] member A member which wants to second the motion.
    # @return [true, false] Whether or not the member is allowed to second the motion.
    def permit_second?(member)
    end

    # Indicates whether or not a given member is allowed to object a motion.
    # @param [Member] member A member which wants to object the motion.
    # @return [true, false] Whether or not the member is allowed to object the motion.
    def permit_object?(member)
    end

    # Indicates whether or not a given member is allowed to vote on a motion.
    # @param [Member] member A member which wants to vote on the motion.
    # @return [true, false] Whether or not the member is allowed to vote on the motion.
    def permit_vote?(member)
    end

    # Schedule automatic updates needed by the state.
    # @see #schedule_updates_in
    def schedule_updates
    end

    # Updates the state of a motion given an amount of time has passed
    # depending on the context of the current state.
    def scheduled_update(time_elapsed)
    end

  private

    # Schedule automatic updates needed by the state in the given elapsed time.
    #
    # This creates a background job that tries to update the motion once the
    # given amount of times has passed.
    def schedule_updates_in(*times)
      times.each { |time| ScheduledMotionUpdate.in(time, @motion) }
    end
    alias :schedule_update_in :schedule_updates_in

    def send_email(notification)
      ActiveMemberNotifier.deliver(notification, @motion)
    end
  end
end
