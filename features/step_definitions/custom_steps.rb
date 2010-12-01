Given "a member exists named \"$name\" with email \"$email\"" do |name, email|
  Factory.create(:member, :email => email, :name => name)
  Factory.create(:active_membership, :member => @member)
end

Given "I am an active member with the email \"$email\"" do |email|
  @member = Factory.create(:member, :email => email)
  Factory.create(:active_membership, :member => @member)
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


