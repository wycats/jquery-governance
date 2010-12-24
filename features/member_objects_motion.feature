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
    And I press "Object This Motion"
    Then I should see "You have successfully objected the motion"

  Scenario: A motion can't be objected more than once by the same member
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Object This Motion"
    Then I should not see "Object This Motion"
