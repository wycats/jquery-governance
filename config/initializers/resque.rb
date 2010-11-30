resque_config = YAML.load(File.open("#{File.dirname(__FILE__)}/../resque.yml").read)
redis         = resque_config[Rails.env]

if redis
  Resque.redis = redis
else
  raise StandardError.new("Redis not defined for #{Rails.env}")
end
