Feature: Population Count
		
		As a user, I want to get information on population count, 
		for all ages and race for a given set of states.
		
		Scenario: Load Main Page
			Given I am on the main page
			And I have not selected a query
			Then my two states should be white

		Scenario: Query Data Set
			Given I am on the main page
			When I query for male population count
			Then State 42 should match 6190363
			And State 34 should match 4279600

		Scenario: No initial results
			Given I am on the main page
			Then there should be no results yet

		Scenario: Navigate to results page
			Given I am on the main page
			When I query for male population count
			Then it should navigate to results page

		Scenario: Database Check
			Given I am on the main page
			When I query for 42
			Then the database should contain an entry for 42

#		Scenario: Submit Query
#			Given I am on the main page
#			When I select a query
#			Then my results should be shown

#		Scenario: Population Count Males
#			Given I am on the main page
#			And I select Population of Males
#			Then the states should be colored appropriately

#		Scenario: State Hover
#			Given I am on the main page
#			And I am viewing a result
#			And I mouse over a state
#			Then I should see that states value
			
#		Scenario: Population Count with race and age
#			Given I select a query specifying age and race
#			Then my results are shown on the map
#			And the results are filtered by race and age
			
#		Scenario: Population Count with race
#			Given I Submit Query specifying race
#			Then my results are shown on the map
#			And the results includes all ages
		
#		Scenario: Population Count with age
#			Given I Submit Query specifying age
#			Then my results are shown on the map
#			And the results includes all races