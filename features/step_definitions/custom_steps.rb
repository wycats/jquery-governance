require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am logged in as an "([^"]*)" member$/ do |member_type|
  @current_member = Factory.create(:"#{member_type}_membership").member
  visit "/sessions_backdoor/#{@current_member.email}"
end

