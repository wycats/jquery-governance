Feature: Creating and Seconding Motions
  As an active member
  I want to create a motion
  So that others may second it, and begin the voting process

  # The Gov Rules are not explicit about "Active" vs. "Inactive" members
  # being able to create new motions, however within context 
  # it appears that inactive members should not be able to create them.
  Scenario: Fail to create a motion as an inactive member
    Given I am logged in as an expired member
    Then I should not see "New Motion"

  Scenario: Second a motion
    Given I am logged in as an active member
    And an existing "motion" with "title" "jQuery is cool"
    And I am on the motions page
    When I follow "More..."
    Then I should see "jQuery is cool" in the title
    When I press "Second"
    Then I should see "You have successfully seconded the motion."

  Scenario: 'Third' a motion that is not expedited
    Given I am logged in as an active member
    And an existing "motion"
    And with 1 second
    And I am on the motions page
    When I follow "More..."
    And I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should see "The motion is open for objections."

  Scenario: 'Third' a motion that is expedited
    Given I am logged in as an active member
    And an existing "motion" with "title" "jQuery is cool"
    And with 1 second
    And waiting "expedited"
    And I am on the motions page
    When I follow "More..."
    And  I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should not see "The motion is open for objections."

  Scenario: 'Fourth' a motion that is expedited
    Given I am logged in as an active member
    And an existing "motion" with "title" "jQuery is cool"
    And with 2 seconds
    And waiting "expedited"
    And I am on the motions page
    When I follow "More..."
    And  I press "Second"
    Then I should see "You have successfully seconded the motion."
    And I should not see "The motion is open for objections."

  Scenario: A motion fails if we don't have 2 seconds within 24 hours
    Given I am logged in as an active member
    And an existing "motion" with "title" "jQuery is cool"
    And with 1 second
    And with "created at" "2 days ago"
    And I am on the motions page
    Then I should see "Closed"
