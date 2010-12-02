require "redis_runner"

namespace :redis do
  desc "start redis"
  task :start do
    fork do
      Process.daemon

      RedisRunner.start(Rails.env)
    end
  end

  desc "stop redis"
  task :stop do
    RedisRunner.stop(Rails.env)
  end

  desc "restart redis"
  task :restart do
    Rake::Task["redis:stop"].invoke
    sleep 1
    Rake::Task["redis:start"].invoke
  end
end
