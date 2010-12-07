Feature: Application updates motion states

  In order to allow the voting process to occur
  The application
  Should update automatically the motion states

  Background:
    Given these members exist:
      | name          | email              |
      | John Resig    | john@jquery.com    |
      | Yehuda Katz   | yehuda@jquery.com  |
      | Paul Irish    | paul@jquery.com    |
      | Brandon Aaron | brandon@jquery.com |
      | Mike Alsup    | mike@jquery.com    |

  Scenario: A motion isn't seconded
    When the member "John Resig" creates a motion titled "jQuery should be even more awesome"
    And no member seconds the motion titled "jQuery should be even more awesome"
    And 48 hours has passed
    Then the motion titled "jQuery should be even more awesome" fails

  Scenario: A motion is seconded one time
    When the member "John Resig" creates a motion titled "jQuery should be even more awesome"
    And the member "Yehuda Katz" seconds the motion titled "jQuery should be even more awesome"
    And 48 hours has passed
    Then the motion titled "jQuery should be even more awesome" fails

  Scenario: An expedited motion isn't seconded
    When the member "John Resig" creates an expedited motion titled "jQuery should be even more awesome"
    And no member seconds the motion titled "jQuery should be even more awesome"
    And 48 hours has passed
    Then the motion titled "jQuery should be even more awesome" fails

  Scenario: An expedited motion is seconded one time
    When the member "John Resig" creates an expedited motion titled "jQuery should be even more awesome"
    And the member "Yehuda Katz" seconds the motion titled "jQuery should be even more awesome"
    And 48 hours has passed
    Then the motion titled "jQuery should be even more awesome" fails

  Scenario: An expedited motion is seconded two times
    When the member "John Resig" creates an expedited motion titled "jQuery should be even more awesome"
    And the following members seconds the motion titled "jQuery should be even more awesome"
      | name        |
      | Yehuda Katz |
      | Paul Irish  |
    And 48 hours has passed
    Then the motion titled "jQuery should be even more awesome" is in discussion

  Scenario: A motion isn't objected
    When the member "John Resig" creates a motion titled "jQuery should be even more awesome"
    And the following members seconds the motion titled "jQuery should be even more awesome"
      | name        |
      | Yehuda Katz |
      | Paul Irish  |
    And 24 hours has passed
    Then the motion titled "jQuery should be even more awesome" is being voted

  Scenario: A motion is objected
    When the member "John Resig" creates a motion titled "jQuery should be even more awesome"
    And the following members seconds the motion titled "jQuery should be even more awesome"
      | name        |
      | Yehuda Katz |
      | Paul Irish  |
    And the member "Brandon Aaron" objects a motion titled "jQuery should be even more awesome"
    And 24 hours has passed
    Then the motion titled "jQuery should be even more awesome" is in discussion
    When 24 hours has passed
    Then the motion titled "jQuery should be even more awesome" is being voted

  Scenario: A motion doesn't get enough votes
    When the member "John Resig" creates a motion titled "jQuery should be even more awesome"
    And the following members seconds the motion titled "jQuery should be even more awesome"
      | name        |
      | Yehuda Katz |
      | Paul Irish  |
    And 24 hours has passed
    And the following members votes affirmatively the motion titled "jQuery should be even more awesome"
      | name        |
      | John Resig  |
      | Yehuda Katz |
    And 48 hours has passed
    Then the motion titled "jQuery should be even more awesome" fails

  Scenario: A motion is approved
    When the member "John Resig" creates a motion titled "jQuery should be even more awesome"
    And the following members seconds the motion titled "jQuery should be even more awesome"
      | name        |
      | John Resig  |
      | Yehuda Katz |
    And 24 hours has passed
    And the following members votes affirmatively the motion titled "jQuery should be even more awesome"
      | name          |
      | John Resig    |
      | Yehuda Katz   |
      | Paul Irish    |
      | Brandon Aaron |
    And 48 hours has passed
    Then the motion titled "jQuery should be even more awesome" is approved
