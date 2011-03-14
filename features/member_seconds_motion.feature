Feature: Member seconds motion

  In order to bring a motion to a vote
  As an active member
  I want to second a motion

  Background:
    Given these members exist:
      | name          | email              |
      | John Resig    | john@jquery.com    |
      | Yehuda Katz   | yehuda@jquery.com  |
      | Paul Irish    | paul@jquery.com    |
      | Brandon Aaron | brandon@jquery.com |
      | Mike Alsup    | mike@jquery.com    |
      | Richard Worth | richard@jquery.com |

  Scenario: A motion is seconded but still needs more seconds to been brough to discussion
    Given the member "John Resig" has created a motion titled "jQuery is cool"
    And I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Second This Vote"
    Then I should see "You have successfully seconded the vote."
    And I should see "Currently waiting for seconds"

  Scenario: A motion is seconded enough times to been brough to discussion
    Given the member "John Resig" has created a motion titled "jQuery is cool"
    And the member "Paul Irish" has seconded a motion titled "jQuery is cool"
    And I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Second This Vote"
    Then I should see "You have successfully seconded the vote."
    And I should see "Currently being discussed"

  Scenario: An expedited motion is seconded but still needs more seconds to been brough to a vote
    Given the member "John Resig" has created an expedited motion titled "jQuery is cool"
    And the member "Paul Irish" has seconded a motion titled "jQuery is cool"
    And I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Second This Vote"
    Then I should see "You have successfully seconded the vote."
    And I should see "Currently waiting for seconds"

  Scenario: An expedited motion is seconded enough times to been brough to a vote
    Given the member "John Resig" has created an expedited motion titled "jQuery is cool"
    And the following members have seconded a motion titled "jQuery is cool"
      | name          |
      | Paul Irish    |
      | Brandon Aaron |
    And I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Second This Vote"
    Then I should see "You have successfully seconded the vote."
    And I should see "Currently being voted"

  Scenario: A motion can't be seconded by it's creator
    Given the member "John Resig" has created an expedited motion titled "jQuery is cool"
    And I am signed in as "John Resig"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I should not see "Second This Vote"

  Scenario: A motion can't be seconded more than once by the same member
    Given the member "John Resig" has created a motion titled "jQuery is cool"
    And I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Second This Vote"
    Then I should not see "Second This Vote"
