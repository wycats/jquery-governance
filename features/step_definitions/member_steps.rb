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

Given "a member exists named \"$name\" with email \"$email\"" do |name, email|
  Factory.create(:member, :email => email, :name => name)
  Factory.create(:active_membership, :member => @member)
end

Given "I am an active member with the email \"$email\"" do |email|
  @member = Factory.create(:member, :email => email)
  Factory.create(:active_membership, :member => @member)
end

Given "I am an expired member with the email \"$email\"" do |email|
  @member = Factory.create(:member, :email => email)
  Factory.create(:expired_membership, :member => @member)
end

# Allows setting name and email
Given "I am an active member named \"$name\"" do |name|
  @member = Factory.create(:member, :name => name)
  Factory.create(:active_membership, :member => @member)
end

Given "I log in" do
  Given "I am on the sign in page"
  And "I fill in \"#{@member.email}\" for \"Email\""
  And "I fill in \"#{@member.password}\" for \"Password\""
  And "I press \"Sign in\""
end

Given  /^(?:|I )am logged in$/ do
  Given "I log in"
end

Given /^these (?:other )members exist:$/ do |table|
  table.rows.each do |name, email|
    Given %{a member exists named "#{name}" with email "#{email}"}
  end
end

When /^I follow the edit link for "([^"]*)"$/ do |arg1|
  with_scope("tr:contains('#{arg1}')") do
    click_link( I18n.t("admin.members.actions.edit_member") )
  end
end


