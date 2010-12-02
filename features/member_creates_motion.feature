Feature: Active member creates motion
  As an active member
  I want to create a motion
  So that others may second it, and begin the voting process

  Scenario: I am an active member 
    Given I am signed in as an active member
    When I follow "New Motion"
    And I fill in "Title" with "jQuery should take over the JS world."
    And I press "Create Motion"
    Then I should see "New motion was created successfully"
