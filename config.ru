# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'resque/server'
# run JqueryVoting::Application

run Rack::URLMap.new(
  '/'       => JqueryVoting::Application,
  '/resque' => Resque::Server.new
)
