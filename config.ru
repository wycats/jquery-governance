# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'resque/server'
# run JqueryVoting::Application

if RESQUE_SERVER_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == RESQUE_SERVER_PASSWORD
  end
end

run Rack::URLMap.new(
  '/'       => JqueryVoting::Application,
  '/resque' => Resque::Server.new
)
