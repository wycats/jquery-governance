Feature: Admin manages members
  In order to control which individuals can vote on motions
  An administrator
  Must manage user accounts for the governance tool

  Background:
    Given I am signed in as an active admin member called "Yehuda Katz"

  Scenario: View all users
    Given these other members exist:
      | name       | email              |
      | John Resig | jresig@example.org |
      | Paul Irish | paul@example.com   |
    When I go to the members admin page
    Then I should see "Manage Members"
    And I should see "Yehuda Katz"
    And I should see "John Resig"
    And I should see "Paul Irish"

  Scenario: Create new member
   Given I am on the members admin page
     And a approved motion titled "Add Voting Member 'Sam Spade'"
    When I follow "Add new member"
     And I fill in "Name" with "Sam Spade"
     And I fill in "Email" with "sspade@gumshoes.com"
     And I select "Add Voting Member 'Sam Spade'" from "Motion Reference"
     And I check "Is admin"
     And I press "Add new member"
    Then I should be on the members admin page
     And I should see "Sam Spade"
     And I should see "Member added"

  Scenario: Validation failure on create
    Given I am on the members admin page
    When I follow "Add new member"
    And I fill in "Name" with ""
    And I fill in "Email" with ""
    And I press "Add new member"
    Then I should see "Member could not be created"
    And I should see "can't be blank"

  Scenario: Update existing member
    Given these other members exist:
      | name       | email              |
      | John Resig | jresig@example.org |
      | Paul Irish | paul@example.com   |
    When I go to the members admin page
    And I follow the edit link for "Paul Irish"
    Then the "Name" field should contain "Paul Irish"
    When I fill in "Name" with "Donald Duck"
    And I press "Update member info"
    Then I should be on the edit member admin page for "Donald Duck"
    And the "Name" field should contain "Donald Duck"
    And I should see "Member updated"

  Scenario: Terminate a member's membership
    Given these other members exist:
      | name       | email              |
      | John Resig | jresig@example.org |
      | Paul Irish | paul@example.com   |
    And a approved motion titled "Remove Voting Member 'Paul Irish'"
    When I go to the members admin page
    And I follow the edit link for "Paul Irish"
    And I follow "End membership"
    And I select "Remove Voting Member 'Paul Irish'" from "Motion Reference"
    And I press "Terminate membership"
    Then I should be on the membership history page for "Paul Irish"
    And I should see "No active memberships"

  Scenario: Add a new membership to a member
    Given the expired member "Paul Irish" exists
    And a approved motion titled "Add Voting Member 'Paul Irish'"
    When I go to the members admin page
    And I follow the edit link for "Paul Irish"
    And I follow "Renew membership"
    And I select "Add Voting Member 'Paul Irish'" from "Motion Reference"
    And I press "Renew membership"
    Then I should be on the membership history page for "Paul Irish"
    And I should see "Membership successfully renewed"
