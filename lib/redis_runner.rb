require 'uri'

class RedisRunner
  def self.start(env)
     exec("echo port #{uri(env).port} | redis-server -")
  end

  def self.stop(env)
    `echo "SHUTDOWN" | nc #{uri(env).host} #{uri(env).port}`
  end

  def self.uri(env)
    @resque_config ||= YAML.load(File.open("#{File.dirname(__FILE__)}/../config/resque.yml").read)
    @redis         ||= @resque_config[env]

    raise "Redis undefined for #{env}" unless @redis

    @uri ||= URI.parse("http://#{@redis}")
  end
end
