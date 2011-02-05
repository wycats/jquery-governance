module SyncResque
  class << self
    def reset
      @elapsed_time = 0
      Resque.redis.flushall
    end

    def handle_delayed_items(elapsed_time=0)
      @elapsed_time += elapsed_time
      Resque::Scheduler.handle_delayed_items(@elapsed_time.from_now.to_i)
      worker.process while Resque.size("scheduled_motion_update") > 0
    end

    def worker
      @worker ||= Resque::Worker.new("*")
    end
  end
end

def Time.update_passed_hours(hours)
  @passed_hours ||= 0
  @passed_hours += hours.to_i.hours
end

def Time.reset_passed_hours
  @passed_hours = 0
end

def Time.now
  Time.new + (@passed_hours || 0)
end

Before do
  Time.reset_passed_hours
  SyncResque.reset
end
