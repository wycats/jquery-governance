Feature: Member seconds motion
  As an active member
  I want to create a motion
  So that others may second it, and begin the voting process

  @wip
  Scenario: I am the first to second a motion
    Given I am signed in as an active member
    And a motion titled "jQuery is cool" exists
    And I am on the motions page
    When I follow "More..."
    Then I should see "jQuery is cool"
    When I press "Second"
    Then I should see "You have successfully seconded the motion."

  @wip
  Scenario: I am the second to second a motion that is not expedited
    Given I am signed in as an active member
    And a motions with one second exists
    And I am on the motions page
    When I follow "More..."
    And I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should see "The motion is open for objections."

  @wip
  Scenario: I am the second to second a motion that is expedited
    Given I am signed in as an active member
    And an expedited motion with one second exists
    And I am on the motions page
    When I follow "More..."
    And  I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should not see "The motion is open for objections."

  @wip
  Scenario: I am the third to second a motion that is expedited
    Given I am signed in as an active member
    And an expedited motion with two seconds exists
    And I am on the motions page
    When I follow "More..."
    And  I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should not see "The motion is open for objections."

  @wip
  Scenario: A motion receives less than two motions in 24 hours
    Given I am signed in as an active member
    And a motion created "2 days ago" with one second exists
    And I am on the motions page
    Then I should see "Closed"
