Given /^a new graph$/ do
  @graph = CiteRank::CitationGraph.new
end

When /^I add (\d+) citations?$/ do |number|
  generate_citations(number).each { |c| @graph.citation(c[0], c[1]) }
end

Then /^the graph should have (\d+) citations?$/ do |number|
  @graph.citations.count.should == number.to_i
end

Given /^the Wikipedia example graph$/ do
  @graph = wikipedia_example_graph
end

When /^I ask for the number of nodes$/ do
  @result = @graph.nodes.count
end

Then /^I should see (\d+)$/ do |number|
  @result.should == number.to_i
end


private

  def generate_citations(number)
    array = Array.new(number.to_i)
    array.map { |c| [rand(10).to_i, rand(10).to_i] }
  end

  def wikipedia_example_graph
    #http://en.wikipedia.org/wiki/File:PageRanks-Example.svg
    graph = CiteRank::CitationGraph.new
    graph.citation(1, 2)
    graph.citation(2, 1)
    graph.citation(3, 0)
    graph.citation(3, 1)
    graph.citation(4, 3)
    graph.citation(4, 1)
    graph.citation(4, 5)
    graph.citation(5, 4)
    graph.citation(5, 1)
    graph.citation(6, 1)
    graph.citation(6, 4)
    graph.citation(7, 1)
    graph.citation(7, 4)
    graph.citation(8, 1)
    graph.citation(8, 4)
    graph.citation(9, 4)
    graph.citation(10, 4)

    return graph
  end
      

  

