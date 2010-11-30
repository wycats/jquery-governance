desc "Sets up the application for development"
task :setup => ["setup:bundle", "setup:copy_default_files"]

namespace :setup do

  desc "Installs required gems"
  task :bundle do
    system %{bundle}
  end

  desc "Copies needed files into place (.rvmrc)"
  task :copy_default_files do
    if File.exists?(".rvmrc.example") && !File.exists?(".rvmrc")
      cp ".rvmrc.example", ".rvmrc"
    end
  end

end