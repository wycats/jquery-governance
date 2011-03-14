Feature: Member votes motion

  In order to state whether I agree with it or not
  As an active member
  I want to vote a motion

  Background:
    Given these members exist:
      | name          | email              |
      | John Resig    | john@jquery.com    |
      | Yehuda Katz   | yehuda@jquery.com  |
      | Paul Irish    | paul@jquery.com    |
      | Brandon Aaron | brandon@jquery.com |
      | Mike Alsup    | mike@jquery.com    |
      | Richard Worth | richard@jquery.com |
    And the member "John Resig" has created a motion titled "jQuery is cool"
    And the following members have seconded a motion titled "jQuery is cool"
      | name          |
      | Paul Irish    |
      | Brandon Aaron |
    And 24 hours has passed

  Scenario: A motion is voted positively
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Vote Aye On This Vote"
    Then I should see "You have successfully voted the vote"

  Scenario: A motion is voted negatively
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Vote Nay On This Vote"
    Then I should see "You have successfully voted the vote"

  Scenario: A motion can't be voted more than once by the same member
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page
    And I follow "jQuery is cool"
    And I press "Vote Aye On This Vote"
    Then I should not see "Vote Aye On This Vote"
    And I should not see "Vote Nay On This Vote"
