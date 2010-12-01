require "spec_helper"

describe "The application itself" do
  it "has no malformed whitespace" do
    Dir.chdir(File.expand_path("../..", __FILE__)) do
      files = `git ls-files`.split("\n").find_all do |filename|
        ignore = %w{public/javascripts/rails.js public/javascripts/jquery.js features/support/env.rb features/step_definitions/web_steps.rb lib/tasks/cucumber.rake}
        !ignore.include?(filename) && filename !~ /\.gitmodules|fixtures|\.png$|\.jp(e)g$|\.gif$/
      end
      files.should be_well_formed
    end
  end
end
