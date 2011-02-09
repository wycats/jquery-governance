Feature: Member withdraws motion

  In order stop a motion being bringed to a vote
  As an active member
  I want to withdraw a motion

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

  Scenario: A motion waiting for seconds is withdrawn
    Given I am signed in as "John Resig"
    When I go to the motions page for "jQuery is cool"
    And I press "Withdraw This Motion"
    Then I should see "You have successfully withdrawn the motion"
    And the motion titled "jQuery is cool" should be closed

  Scenario: Another member can't withdraw a motion waiting for seconds
    Given I am signed in as "Yehuda Katz"
    When I go to the motions page for "jQuery is cool"
    Then I should not see "Withdraw This Motion"

  Scenario: A motion beign discussed is withdrawn
    Given the following members have seconded a motion titled "jQuery is cool"
      | name          |
      | Paul Irish    |
      | Brandon Aaron |
    And I am signed in as "John Resig"
    When I go to the motions page for "jQuery is cool"
    And I press "Withdraw This Motion"
    Then I should see "You have successfully withdrawn the motion"
    And the motion titled "jQuery is cool" should be closed

  Scenario: Another member can't withdraw a motion being discussed
    Given the following members have seconded a motion titled "jQuery is cool"
      | name          |
      | Paul Irish    |
      | Brandon Aaron |
    And I am signed in as "Yehuda Katz"
    When I go to the motions page for "jQuery is cool"
    Then I should not see "Withdraw This Motion"

  Scenario: A motion being voted can't be withdrawn
    Given the following members have seconded a motion titled "jQuery is cool"
      | name          |
      | Paul Irish    |
      | Brandon Aaron |
    And 24 hours has passed
    And I am signed in as "Yehuda Katz"
    When I go to the motions page for "jQuery is cool"
    Then I should not see "Withdraw This Motion"
