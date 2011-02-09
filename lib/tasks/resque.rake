require 'resque/tasks'
task "resque:setup" => :environment

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
