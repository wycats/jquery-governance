Feature: Member views motion

  Scenario: I am an active member viewing the motions
    Given I am signed in as an active member
    And a motion titled "jQuery is cool" exists in the "waitingsecond" state
    And a motion titled "Vader vs Rocky" exists in the "voting" state

    When I go to the motions page
    Then I should see "Waiting For Seconds"
    And I should see "Voting"

  Scenario: I am an active member viewing a motion
    Given I am signed in as an active member
    And a motion titled "jQuery is cool" exists in the "discussing" state

    When I go to the motions page for "jQuery is cool"
    Then I should see "Discussing"

  Scenario: I am an active member viewing a motion I created
    Given I am signed in as an active member called "Member"
    And the member "Member" creates a motion titled "Make it work"

    When I go to the motions page for "Make it work"
    Then I should not see "Second This Motion"
