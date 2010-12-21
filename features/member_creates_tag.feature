Feature: Member creates tag
  As an active Member
  I want to create a tag
  So that I can capture whaht the group has decided on in the past.

  Scenario: Active member creates a tag
    Given I am signed in as an active member
    And I am on the admin tags page
    When I fill in "Tag name" with "mojo"
    And I press "Add"
    Then I should see "mojo" in the list of tags

  @wip
  Scenario: Active member removes a tag
    Given I am signed in as an active member
    And   an existing "tag" with "name" "mojo"
    And   I am on the admin tags page
    When  I press Remove
    Then  I should be on the admin tags page
    And   I should not see "mojo"

  Scenario: Non-active member cannot create a tag
    Given I am signed in as an inactive member
    And I am on the admin tags page
    Then I should not see an "Add" submit button
    And I should not see "Remove"
