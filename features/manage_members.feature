Feature: Manage members
In order to control which individuals can vote on motions
An administrator
Must manage user accounts for the governance tool 

Background:
  Given I have signed in with:
    | name        | email            | password |
    | Yehuda Katz | wycats@gmail.com | p4ssw0rd |
    And I am an active member
    
Scenario: View all users
  When I go to the members page
  Then I should see "jQuery Admin"
    