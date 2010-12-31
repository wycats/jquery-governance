Feature: User searches motion

  In order to find the motion that I want to vote
  As a User
  I want to search for motions

  Background:
    Given the following motions exist:
      | title           | description                   | rationale                             | state_name    |
      | Sample Motion 1 | This is the first test motion | Motions are good to have              | discussing    |
      | Sample Vote   2 | This second motiom is cool    | We need more motions to look cool     | voting        |
      | Test   Motion 3 | Third test motions are bad    | Too many motions makes us pretentious | voting        |

  Scenario: Member navigates to the search page
    Given I am signed in as an active member
      And I am on the home page
     When I follow "Search Motions"
     Then I should be on the search page

  Scenario: Member searches for a motion
    Given I am signed in as an active member
     When I go to the search page
      And I fill in "Sample" for my search terms
      And I press "Search for motions"
     Then I should be on the search results page
      And I should see "Sample Motion 1"
      And I should see "Sample Vote 2"

  Scenario: Public user only see results he has permission to see
    Given I am on the search page
      And I fill in "Sample" for my search terms
      And I press "Search for motions"
     Then I should be on the search results page
      But I should not see "Sample Motion 1"
      And I should see "Sample Vote 2"


