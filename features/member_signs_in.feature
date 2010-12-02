Feature: Member signs in
  As an active member
  I want to sign in
  So that I can do things anonymous users aren't allowed to

  Background:
    Given there is an active member with email "TestMan42@example.com" and password "secret"
    And I am on the sign in page

  Scenario: I type the correct credentials
    When I fill in "Email" with "TestMan42@example.com"
    And I fill in "Password" with "secret"
    And I press "Sign in"
    Then I should see "Signed in successfully."

  Scenario: I type incorrect credentials
    When I fill in "Email" with "TestMan41@example.com"
    And I fill in "Password" with "fail"
    And I press "Sign in"
    Then I should not see "Signed in successfully."