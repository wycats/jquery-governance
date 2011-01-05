desc "Sets up the application for development"
task :setup =>  [
                  "setup:bundle",              # Bundler, keep this first
                  "setup:copy_default_config", # Create database.yml
                  "doc:app",                   # YARD docs
                  "db:create",
                  "db:schema:load",
                  "db:fixtures:load",           # Load up the development database with test data
                  "setup:intro"                # tl;dr, keep this last
                ]

namespace :setup do
  desc "Installs required gems"
  task :bundle do
    system %{bundle}
  end

  desc "Copies default database.yml into place"
  task :copy_default_config do
    cp "config/database.yml.example", "config/database.yml"
  end

  desc "Hello, my name is ________"
  task :intro do
    puts "To get started: review the README and doc/README_FOR_APP files, as well as the generated YARD docs."
    puts "  -- The YARD docs for this project can be viewed at doc/index.html --"
  end
end
