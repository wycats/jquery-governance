Feature: Member searches motion

  In order to find the motion that I want to vote
  As a member
  I want to search for motions

  Background:
    Given the following member exists:
      | name          | email              |
      | Yehuda Katz   | yehuda@jquery.com  |
    And the following motions exist:
      | title           | description                       | rationale                             |
      | Sample Motion 1 | This is the first test motion     | Motions are good to have              |
      | Sample Motion 2 | This second motiom is cool        | We need more motions to look cool     |
      | Test   Motion 3 | Third test motions are bad        | Too many motions makes us pretentious |
      And I am signed in as "Yehuda Katz"

  Scenario: Member navigates to the search page
    Given I am on the home page
     When I follow "Search Motions"
     Then I should be on the search page

  Scenario: Member searches for a motion
     When I go to the search page
      And I fill in "Sample" for my search terms
      And I press "Search for motions"
     Then I should be on the search results page
     Then I should see "Your search returned 2 Motions"
      And I should see "Sample Motion 1"
      And I should see "Sample Motion 2"
