Given /^I am signed in as "([^"]*)"$/ do |email_or_name|
  visit new_member_session_path
  email = email_or_name.include?('@') ? email_or_name : Member.find_by_name!(email_or_name).email
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

Given /^I am signed in as an active(:? admin)? member called "([^"]*)"$/ do |admin, name|
  member = Factory.create(:member, :name => name, :is_admin => admin.present?)
  Factory.create(:active_membership, :member => member)
  Given "I am signed in as \"#{member.email}\""
end

Given /^there is an active(:? admin)? member with email "([^"]*)" and password "([^"]*)"$/ do |admin, email, password|
  member = Factory.create(:member, email: email, password: password, is_admin: admin.present?)
  Factory(:active_membership, member: member)
end

Given /^these (?:other )?members exist:$/ do |table|
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

When /^the member "([^"]*)" (?:creates|has created) a(n expedited)? motion titled "([^"]*)"$/ do |member_name, expedited, motion_title|
  Factory(
    :motion,
    :member => Member.find_by_name!(member_name),
    :title => motion_title,
    :expedited => !expedited.blank?
  )
end

When /^no member seconds the motion titled "([^"]*)"$/ do |motion_title|
end

When /^the member "([^"]*)" (?:seconds the|has seconded a) motion titled "([^"]*)"$/ do |member_name, motion_title|
  motion = Motion.find_by_title!(motion_title)
  motion.second(Member.find_by_name!(member_name))
end

When /^the following members (?:seconds the|have seconded a) motion titled "([^"]*)"$/ do |motion_title, table|
  table.rows.each do |name, email|
    When "the member \"#{name}\" seconds the motion titled \"#{motion_title}\""
  end
end

When /^the member "([^"]*)" objects a motion titled "([^"]*)"$/ do |member_name, motion_title|
  motion = Motion.find_by_title!(motion_title)
  motion.object(Member.find_by_name!(member_name))
end

When /^the following members votes affirmatively the motion titled "([^"]*)"$/ do |motion_title, table|
  motion = Motion.find_by_title!(motion_title)
  table.rows.each do |member_name|
    motion.vote(Member.find_by_name!(member_name), true)
  end
end

semantic_suffixes({ 'in the author section' => '.author' })
