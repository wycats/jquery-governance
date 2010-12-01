Given /^I am signed in as an active member$/ do
  visit new_member_session_path
  fill_in 'Email', with: active_member.email
  fill_in 'Password', with: active_member.password
  click_button 'Sign in'
end
