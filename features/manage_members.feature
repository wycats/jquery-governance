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
  Scenario: Validation failure on create
    When I go to the members admin page
    And I follow "Add new member"
    Then I should be on the new member admin page
    And I should see "New member" within "header"
    When I fill in "member[name]" with ""
    And I fill in "member[email]" with ""
    And I press "Add new member"
    Then I should be on /admin/members
    And I should see "New member"
    And I should see "Member could not be created"
    And the "member[name]" field should contain ""

  Scenario: Update existing member
    Given these other members exist:
      | name       | email              |
      | John Resig | jresig@example.org |
      | Paul Irish | paul@example.com   |
    When I go to the members admin page
    And I follow the edit link for "Paul Irish"
    Then I should be on the edit member admin page for "Paul Irish"
    And I should see "Edit member info" within "header"
    And the "member[name]" field should contain "Paul Irish"
    And the "member[email]" field should contain "paul@example.com"
    When I fill in "member[name]" with "Donald Duck"
    And I press "Update member info"
    Then I should be on the edit member admin page for "Donald Duck"
    And the "member[name]" field should contain "Donald Duck"
    And I should see "Member updated"

  @wip
  Scenario: Delete member
    Given these other members exist:
      | name              | email              |
      | John Resig        | jresig@example.org |
      | Grandmaster Flash | gmflash@adobe.com  |
    When I go to the members admin page
    And I follow the edit link for "Grandmaster Flash"
    Then I should be on the edit member admin page for "Grandmaster Flash"
    And I should see "Delete this member"
    When I follow "Delete this member"
    Then I should be on the members admin page
    And I should not see "Grandmaster Flash"
    And I should see "Member deleted"
