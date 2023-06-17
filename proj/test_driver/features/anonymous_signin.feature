Feature: Anonymous Sign-In
  As a user
  I want to be able to sign in anonymously
  So that I can access basic app features

  Scenario: Successful anonymous sign-in
    Given I am on the login page
    When I tap the "anonymous_sign_in" button
    Then I expect the text "Login" to be absent
    And I am on the map screen
    And I expect the text "Profile" to be absent
