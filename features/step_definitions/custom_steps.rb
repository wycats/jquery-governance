Given /^I am logged in as an active member$/ do 
   @current_member = Factory.create(:"active_membership").member
   Given "I go to the sign in page"
   When "I fill in \"Email\" with \"#{@current_member.email}\""
   And "I fill in \"Password\" with \"secret\""
   And "I press \"Sign in\""
end
