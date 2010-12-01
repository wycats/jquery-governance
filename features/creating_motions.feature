Feature: Creating and Seconding Motions
  As an active member
  I want to create a motion
  So that others may second it, and begin the voting process

  Scenario: Create a motion as an active member 
    Given I am logged in as an active member
    When I press "New Motion"
    And I fill in "title" with "jQuery should take over the JS world."
    And I press "Create Motion"
    Then I should see "New motion was successfully created"
