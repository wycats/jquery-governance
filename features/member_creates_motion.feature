Feature: Member creates motion

  In order to bring a motion to a vote
  As an active member
  I want to create a motion

  Background:
    Given these members exist:
      | name          | email              |
      | John Resig    | john@jquery.com    |
      | Yehuda Katz   | yehuda@jquery.com  |

  Scenario: A motion is created
    Given I am signed in as "John Resig"
     When I am on the home page
      And I follow "New Motion"
      And I fill in "Title" with "jQuery should take over the JS world"
      And I fill in "Description" with "Replace all websites' JS with jQuery."
      And I fill in "Rationale" with "Because it's just that cool."
      And I press "Create Motion"
     Then I should be on the motions page for "jQuery should take over the JS world"
      And I should see "New motion was created successfully"
      And I should see "jQuery should take over the JS world"
      And I should see "Replace all websites' JS with jQuery."
      And I should see "Because it's just that cool."

  Scenario: I am an inactive member
    Given I am signed in as an inactive member
    Then I should not see "New Motion"
