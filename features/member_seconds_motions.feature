Feature: Creating and Seconding Motions
  As an active member
  I want to create a motion
  So that others may second it, and begin the voting process

  Background:
    Given I am signed in as an active member
    And an existing "motion" with "title" "jQuery is cool"

  Scenario: Second a motion
    And I am on the motions page
    When I follow "More..."
    Then I should see "jQuery is cool" in the title
    When I press "Second"
    Then I should see "You have successfully seconded the motion."

  Scenario: 'Third' a motion that is not expedited
    Given the motion has 1 second
    And I am on the motions page
    When I follow "More..."
    And I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should see "The motion is open for objections."

  Scenario: 'Third' a motion that is expedited
    Given the motion has 1 second
    And it's waiting "expedited"
    And I am on the motions page
    When I follow "More..."
    And  I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should not see "The motion is open for objections."

  Scenario: 'Fourth' a motion that is expedited
    Given the motion has 2 seconds
    And it's waiting "expedited"
    And I am on the motions page
    When I follow "More..."
    And  I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should not see "The motion is open for objections."

  Scenario: A motion fails if we don't have 2 seconds within 24 hours
    Given the motion has 1 second
    And with "created at" "2 days ago"
    And I am on the motions page
    Then I should see "Closed"
