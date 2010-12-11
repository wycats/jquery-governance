Feature: Member sign in validations
  As an active member
  I want see error messages if the signin fails
  So that I know what I've done wrong

  Background:
    Given there is an active member with email "TestMan42@example.com" and password "secret"
    And I am on the sign in page

    Scenario: I type incorrect credentials
      When I fill in "Email" with "TestMan41@example.com"
      And I fill in "Password" with "fail"
      And I press "Sign in"
      Then I should see "Invalid email or password."
