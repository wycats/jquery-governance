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
  Scenario: Non-active member cannot create a tag
    Given I am signed in as an inactive member
    And I am on the tags page
    When I fill in "Add a tag" with "mojo"
    And I press "Add"
    Then I should see "mojo" in the list of tags
