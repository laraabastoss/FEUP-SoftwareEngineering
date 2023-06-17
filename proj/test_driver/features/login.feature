Feature: Login
  As a registered user
  I want to login to the app
  So that I can access my account

  Scenario: Successful Login
    Given I am on the login page
    When I fill the "email" field with "teste123456@gmail.com"
    And I fill the "password" field with "teste123"
    And I tap the "login" button
    And I wait 2 seconds
    Then I expect the text "Login" to be absent
    And I am on the map screen

  Scenario: Unsuccessful Login
    Given I am on the login page
    When I fill the "email" field with "t@gmail.com"
    And I fill the "password" field with "wrongpassword"
    And I tap the "login" button
    And I wait 2 seconds
    Then I expect the text "Login" to be present

