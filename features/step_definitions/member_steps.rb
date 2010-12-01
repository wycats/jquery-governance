Given /^I am signed in as an active member$/ do
  visit new_member_session_path
  fill_in 'Email', with: active_member.email
  fill_in 'Password', with: 'secret'
  click_button 'Sign in'
end

Given /^there is an active member with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  member = Factory(:member, email: email, password: password)
  Factory(:active_membership, member: member)
end
