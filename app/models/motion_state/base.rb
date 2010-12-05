module MotionState
  class Base
    def initialize(motion)
      @motion = motion
    end

    def permit?(action, member)
      method = "permit_#{action}?"
      public_send(method, member) if self.respond_to?(method)
    end

    def permit_see?(member)
    end

    def permit_second?(member)
    end

    def permit_vote?(member)
    end

    def schedule_updates
    end

    def update
    end

    def scheduled_update(time_elapsed)
    end

  private

    def schedule_updates_in(*times)
      times.each do |time|
        Resque.enqueue_at(time.from_now, ScheduledMotionUpdate, @motion.id, @motion.state_name, time)
      end
    end
    alias :schedule_update_in :schedule_updates_in
  end
end
