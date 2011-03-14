
Feature: Member objects motion

  In order to prolong the time to discuss it
  As an active member
  I want to object a motion

  Background:
    Given these members exist:
      | name          | email              |
      | John Resig    | john@jquery.com    |
      | Yehuda Katz   | yehuda@jquery.com  |
      | Paul Irish    | paul@jquery.com    |
      | Brandon Aaron | brandon@jquery.com |
    And the member "John Resig" has created a motion titled "jQuery is cool"
    And the following members have seconded a motion titled "jQuery is cool"
      | name          |
      | Paul Irish    |
      | Brandon Aaron |

  Scenario: A motion is objected
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Object This Vote"
    Then I should see "You have successfully objected the vote"

  Scenario: A motion can't be objected more than once by the same member
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Object This Vote"
    Then I should not see "Object This Vote"

  Scenario: A motion objection is withdrawn
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Object This Vote"
    And I press "Withdraw Objection"
    Then I should see "You have successfully withdrawn your objection"
    And I should see "Object This Vote"

  Scenario: A motion objection is withdrawn during its added discussion time
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Object This Vote"
    And 24 hours has passed
    And I press "Withdraw Objection"
    Then I should see "You have successfully withdrawn your objection"
    And I should see "Vote Aye On This Vote"
    And I should see "Vote Nay On This Vote"

  Scenario: An objection is withdrawn for a motion with several objections during its added discussion time
    Given the member "John Resig" objects the motion titled "jQuery is cool"
    And I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Object This Vote"
    And 24 hours has passed
    And I press "Withdraw Objection"
    Then I should see "You have successfully withdrawn your objection"
    And I should see "Object This Vote"
