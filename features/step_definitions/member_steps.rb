Given /^I am signed in as "([^"]*)"$/ do |email|
  visit new_member_session_path
  fill_in 'Email', with: email
  fill_in 'Password', with: 'secret'
  click_button 'Sign in'
end

Given /^I am signed in as an active member$/ do
  Given "I am signed in as \"#{active_member.email}\""
end

Given /^I am signed in as an inactive member$/ do
  Given "I am signed in as \"#{inactive_member.email}\""
end

Given /^I am signed in as an active member called "([^"]*)"$/ do |name|
  active_member.update_attribute(:name, name)
  Given "I am signed in as \"#{active_member.email}\""
end

Given /^there is an active member with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  member = Factory(:member, email: email, password: password)
  Factory(:active_membership, member: member)
end

Given /^these (?:other )members exist:$/ do |table|
  table.rows.each do |name, email|
    member = Factory(:member, name: name, email: email)
    Factory(:active_membership, member: member)
  end
end

When /^I follow the edit link for "([^"]*)"$/ do |arg1|
  with_scope("tr:contains('#{arg1}')") do
    click_link( I18n.t("admin.members.actions.edit_member") )
  end
end


