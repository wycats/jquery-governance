Given "I am an active member with the email \"$email\"" do |email|
  @member = Factory.create(:member, :email => email)
  Factory.create(:active_membership, :member => @member)
end

And "I log in" do
  Given "I am on the sign in page"
  And "I fill in \"#{@member.email}\" for \"Email\""
  And "I fill in \"#{@member.password}\" for \"Password\""
  And "I press \"Sign in\""
end
