Feature: Admin Member signs in
  As an active admin member
  I want to sign in
  So that I can do things normal active members are not allowed to

  Background:
    Given there is an active admin member with email "theman@example.com" and password "theman"
    And there is an active member with email "someone@example.com" and password "someone"

  Scenario: I attempt to log into the admin page with admin credentials
    When I go to the admin page
    And I fill in "Email" with "theman@example.com"
    And I fill in "Password" with "theman"
    And I press "Sign in"
    Then I should be on the admin page
    And I should see "Signed in successfully."

  Scenario: I attempt to log into the admin page with member credentials
    When I go to the admin page
    And I fill in "Email" with "someone@example.com"
    And I fill in "Password" with "someone"
    And I press "Sign in"
    Then I should be on the motions page
    And I should see "Can not access that area."
