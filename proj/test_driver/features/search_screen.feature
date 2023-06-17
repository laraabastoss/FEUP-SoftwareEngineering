Feature: Tab Navigation
  As a user
  I want to navigate between tabs
  So that I can access different sections of the app

  Scenario: Navigate to search page
    Given I am logged in
    And I tap the "search_icon" icon
    Then I am on the search screen

  Scenario: Navigate back map page from search page
    Given I am logged in
    And I tap the "search_icon" icon
    And I tap the "map_icon" icon
    Then I am on the map screen

  Scenario: Navigate to profile page
    Given I am logged in
    And I tap the "profile_icon" icon
    Then I am on the profile page
