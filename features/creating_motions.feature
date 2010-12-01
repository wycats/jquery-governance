Feature: Creating Motions
  As an active member
  I want to create a motion
  So that others may second it, and begin the voting process

  Scenario: Create a motion as an active member 
    Given I am an active member with the email "TestMember@example.com"
    And I log in
    When I follow "New Motion"
    And I fill in "Title" with "jQuery should take over the JS world."
    And I press "Create Motion"
    Then I should see "New motion was created successfully"
