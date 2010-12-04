Feature: Public browses votes
  In order to learn about what topics jQuery Core is addressing
  As an anonymous visitor
  I want to browse through votes

  Background:
    Given I am an anonymous visitor
    And a motion titled "jQuery should rule the JS World" exists

  Scenario: A visitor sees the a list of votes
    Given I am on the homepage
    Then I should see "jQuery should rule the JS World"
