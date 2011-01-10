Feature: Admin has a dashboard
  In order to control various aspects of the application
  An administrator
  Must have a dashboard

  Background:
    Given I am signed in as an active admin member called "Yehuda Katz"

  Scenario: See available actions
    Given I am on the admin page
    When I follow "Manage Members"
    Then I should be on the members admin page
