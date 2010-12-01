Feature: Manage members
In order to control which individuals can vote on motions
An administrator
Must manage user accounts for the governance tool 

Background:
  Given I am an active member named "Yehuda Katz"
  And am logged in
    
Scenario: View all users
  Given these other members exist:
    | name       | email              |
    | John Resig | jresig@example.org |
    | Paul Irish | paul@example.com   |
  When I go to the members admin page
  Then I should see "Manage members"
  And I should see "Yehuda Katz" within "table.members"
  And I should see "John Resig" within "table.members"
  And I should see "Paul Irish" within "table.members"

@wip
Scenario: Create new member
  When I go to the members admin page
  And I follow "Add new member"
  Then I should be on the new member admin page
  And I should see "New member" within "header"
  When I fill in "member[name]" with "Sam Spade"
  And I fill in "member[email]" with "sspade@gumshoes.com"
  And I check "member[is_admin]"
  And I press "Add new member"
  Then I should be on the members admin page
  And I should see "Sam Spade" within "table.members"
  And I should see "Member added"
 
@wip
Scenario: Update existing member
  Given these other members exist:
    | name       | email              |
    | John Resig | jresig@example.org |
    | Paul Irish | paul@example.com   |
  When I go to the members admin page
  And I follow the edit link for "Paul Irish"
  Then I should be on the edit member page
  And I should see "Edit member info" within "header"
  And the field "member[name]" should contain "Paul Irish"
  And the field "member[email]" should contain "paul@example.com"
  And the checkbox "member[is_admin]" should not be checked
  When I fill in "name" with "Donald Duck"
  And I press "Update member info"
  Then I should be on the members admin page
  And I should see "Donald Duck"
  And I should not see "Paul Irish"
  And I should see "Member updated"

@wip
Scenario: Delete member
  When I go to the members admin page
  And I follow "Edit member" within "some selector"
  Then I should be on the edit member page
  And I should see "Delete this member" within "header a"
  When I follow "Delete this member" within "header a"
  Then I should be on the members admin page
  And I should not see "Donald Duck"
  And I should see "Member deleted"