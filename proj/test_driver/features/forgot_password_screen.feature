Feature: Reset password
  As a registered user who forgot his password
  I want to reset my password
  So that I can access my account again

  Scenario: Successful Login
    Given I am on the login page
    When I tap the "forgot-password" button
    Then I expect the text "Reset Password" to be present