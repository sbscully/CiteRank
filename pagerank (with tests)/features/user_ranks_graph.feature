Feature: user ranks graph

	In order to create a ranked graph of academic papers
	As a user
	I want to rank the graph
			
	Scenario Outline: a star graph
		Given a star graph
		When I ask for the rank of "<node>"
		Then the rank should be "<rank>"

		Scenarios: ranks
			| node	| rank	|
			| 0			| 5			|
			| 1			| 5			|
			| 2			| 90		|
			
	Scenario Outline: uniform rank for a circular graph
		Given a circular graph
		When I ask for the rank of "<node>"
		Then the rank should be "<rank>"

		Scenarios: ranks
			| node	| rank	|
			| 0			| 20		|
			| 1			| 20		|
			| 2			| 20		|
			| 3			| 20		|
			| 4			| 20		|
			
	Scenario Outline: a converging graph
		Given a converging graph
		When I ask for the rank of "<node>"
		Then the rank should be "<rank>"

		Scenarios: ranks
			| node	| rank	|
			| 0			| 5			|
			| 1			| 7.1		|
			| 2			| 87.9	|
			
	Scenario: ranks sum to 100%
		Given the Wikipedia example graph
		When I ask for the rank
		Then it should sum to 100 percent
		
	Scenario Outline: rank the Wikipedia example graph
		Given the Wikipedia example graph
		When I ask for the rank of "<node>"
		Then the rank should be "<rank>"

		Scenarios: ranks
			| node	| rank	|
			| 0			| 3.3		|
			| 1			| 38.4	|
			| 2			| 34.3	|
			| 3			| 3.9		|
			| 4			| 8.1		|
			| 5			| 3.9		|
			| 6			| 1.6		|
			| 7			| 1.6		|
			| 8 		| 1.6		|
			| 9 		| 1.6		|
			| 10		| 1.6		|
	
	Scenario: profile the ranking algorithm
		Given a graph with profiler on
		When I ask for the rank
		Then the profile data should be printed