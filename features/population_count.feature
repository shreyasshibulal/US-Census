Feature: Population Count
		
		As a user, I want to get information on population count, 
		by providing parameters of race and age for a given 
		set of states.
		
		Scenario: Submit Query
			Given I am on the main page
			When I hit submit button
			Then my results should be shown
			
		Scenario: Population Count with race and age
			Given I Submit Query specifying age and race
			Then my results are shown on the map
			And the results are filtered by race and age
			
		Scenario: Population Count with race
			Given I Submit Query specifying race
			Then my results are shown on the map
			And the results includes all ages
		
		Scenario: Population Count with age
			Given I Submit Query specifying age
			Then my results are shown on the map
			And the results includes all races