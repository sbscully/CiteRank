Feature: user builds graph

	In order to create a ranked graph of academic papers
	As a user
	I want to build the graph

	Scenario: add citation
		Given a new graph
		When I add 1 citation
		Then the graph should have 1 citation
		
	Scenario: check nodes
		Given the Wikipedia example graph
		When I ask for the number of nodes
		Then I should see 11
		
	Scenario: find citations to a paper
	
	Scenario: find citations from a paper
		