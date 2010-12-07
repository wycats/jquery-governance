Given /^I am signed in as "([^"]*)"$/ do |email|
  visit new_member_session_path
  fill_in 'Email', with: email
  fill_in 'Password', with: 'secret'
  click_button 'Sign in'
end

Given /^I am signed in as an active member$/ do
  member = Factory.create(:active_membership).member
  Given "I am signed in as \"#{member.email}\""
end

Given /^I am signed in as an inactive member$/ do
  member = Factory.create(:expired_membership).member
  Given "I am signed in as \"#{member.email}\""
end

Given /^I am signed in as an active member called "([^"]*)"$/ do |name|
  member = Factory.create(:member, :name => name)
  Given "I am signed in as \"#{member.email}\""
end

Given /^there is an active member with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  member = Factory.create(:member, email: email, password: password)
  Factory(:active_membership, member: member)
end

Given /^these (?:other )members exist:$/ do |table|
  table.rows.each do |name, email|
    member = Factory.create(:member, name: name, email: email)
    Factory.create(:active_membership, member: member)
  end
end

When /^I follow the edit link for "([^"]*)"$/ do |arg1|
  with_scope("tr:contains('#{arg1}')") do
    click_link( I18n.t("admin.members.actions.edit_member") )
  end
end

semantic_suffixes({ 'in the author section' => '.author' })
