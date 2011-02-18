Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

if Rails.env == 'production'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  resque_config = YAML.load(File.open("#{File.dirname(__FILE__)}/../resque.yml").read)
  redis         = resque_config[Rails.env]

  if redis
    Resque.redis = redis
  else
    raise StandardError.new("Redis not defined for #{Rails.env}")
  end
end

