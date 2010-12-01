Feature: Manage members
In order to control which individuals can vote on motions
An administrator
Must manage user accounts for the governance tool 

Background:
  Given I am an active member named "Yehuda Katz"
  And am logged in
    
Scenario: View all users
  When I go to the members admin page
  Then I should see "Manage members"
  And I should see "Yehuda Katz" within "table.members"

@wip
Scenario: Create new member
  When I go to the members admin page
  And I follow "Add New Member"
  Then I should be on the new member admin page
  And I should see "New Member" within "header"
  When I fill in "name" with "Sam Spade"
  And I fill in "email" with "sspade@gumshoes.com"
  And I check "admin"
  And I press "Add new member"
  Then I should be on the members admin page
  And I should see "Sam Spade"
  And I should see "Member added"
 
@wip
Scenario: Update existing member
  When I go to the members admin page
  And I follow "Edit member" # within "some selector"
  Then I should be on the edit member page
  And I should see "Edit Member" within "header"
  And the field "name" should contain "Sam Spade"
  And the field "email" should contain "sspade@gumshoes.com"
  And the checkbox "admin" should be checked
  When I fill in "name" with "Donald Duck"
  And I press "Update member info"
  Then I should be on the members admin page
  And I should see "Donald Duck"
  And I should see "Member updated"

@wip
Scenario: Delete member
  When I go to the members admin page
  And I follow "Edit member" # within "some selector"
  Then I should be on the edit member page
  And I should see "Delete this member" within "header a"
  When I follow "Delete this member" within "header a"
  Then I should be on the members admin page
  And I should not see "Donald Duck"
  And I should see "Member deleted"