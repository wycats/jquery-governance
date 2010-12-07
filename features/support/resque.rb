module SyncResque
  class << self
    def reset
      @elapsed_time = 0
      Resque.redis.flushall
    end

    def handle_delayed_items(elapsed_time)
      @elapsed_time += elapsed_time
      Resque::Scheduler.handle_delayed_items(@elapsed_time.from_now.to_i)
      worker.process while Resque.size("scheduled_motion_update") > 0
    end

    def worker
      @worker ||= Resque::Worker.new("*")
    end
  end
end

Before { SyncResque.reset }
