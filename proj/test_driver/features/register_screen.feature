Feature: Register
  As an unregistered user
  I want to access the register screen
  So that I can register my account

Scenario: Navigate to Register screen from Login screen

  Given I am on the login page
  When I tap the "register" button
  Then I expect the text "Username" to be present
  And I expect the text "Email" to be present
  And I expect the text "Password" to be present
  And I expect the text "Confirm Password" to be present
  And I expect the text "Register" to be present
  And I expect the text "Already a member?" to be present