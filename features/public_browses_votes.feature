Feature: Public browses votes
  In order to learn about what topics jQuery Core is addressing
  As an anonymous visitor
  I want to browse through votes

  Background:
    Given I am an anonymous visitor
    And a motion titled "jQuery should rule the JS World" exists in the "voting" state

  Scenario: A visitor sees the a list of motions
    Given I am on the homepage
    Then I should see "jQuery should rule the JS World"

  Scenario: A visitor sees details for one of the motions
    Given I am on the homepage
    When I follow "jQuery should rule the JS World"
    And I should see "jQuery should rule the JS World"
    And I should see "Test Member" in the author section

  Scenario: A guest can't see a private motion
    Given these member exist:
      | name          | email              |
      | John Resig    | john@jquery.com    |
    Given the member "John Resig" has created a motion titled "jQuery is cool"
    When I go to the motions page for "jQuery is cool"
    Then I should get a "404" response
    And I should not see "jQuery is cool"
