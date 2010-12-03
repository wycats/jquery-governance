Given /^I am an anonymous visitor$/ do
  visit path_to("the sign out page")  
end

Given /^a motion exists titled "(.+)"$/ do |name|
  Given "I am signed in as an active member"
  When "I follow \"New Motion\""
  And "I fill in \"Title\" with \"#{name}\""
  And "I press \"Create Motion\""
end