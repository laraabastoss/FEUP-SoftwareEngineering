Feature: Filter my search
  As a user
  I want to access the different filters available to me
  So that I can search for the right place to study

  Scenario: Navigate to filters
    Given I am logged in
    And I tap the "search_icon" icon
    And I tap the "filter-action" button
    Then I expect the text "Study Spot Filter" to be present