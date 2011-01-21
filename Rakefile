# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

require 'resque/tasks'
require 'texticle/tasks'

JqueryVoting::Application.load_tasks

namespace :doc do
  desc "Generate YARD docs"
  YARD::Rake::YardocTask.new(:app) do |t|
    t.files += ['app/**/*.rb']
  end
end


