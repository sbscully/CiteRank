class Float
  # 0.666666666 -> 66.7
  def to_percentage
    100 * (self * (10 ** 3)).round / (10 ** 3).to_f
  end
end

When /^I ask for the rank of "([^"]*)"$/ do |node|
  @result = @graph.rank[node.to_i].to_percentage
end

Then /^the rank should be "([^"]*)"$/ do |rank|
  @result.should == rank.to_f
end

When /^I ask for the rank$/ do
  @result = @graph.rank
end

Then /^it should sum to 100 percent$/ do
  @result.values.reduce(:+).to_percentage.should == 100
end

Given /^a star graph$/ do
  @graph = CiteRank::CitationGraph.new
  @graph.citation(1, 2)
  @graph.citation(0, 2)
  @graph.citation(2, 2)
end

Given /^a circular graph$/ do
  @graph = CiteRank::CitationGraph.new
  @graph.citation(0, 1)
  @graph.citation(1, 2)
  @graph.citation(2, 3)
  @graph.citation(3, 4)
  @graph.citation(4, 0)
end

Given /^a converging graph$/ do
  @graph = CiteRank::CitationGraph.new
  @graph.citation(0, 1)
  @graph.citation(0, 2)
  @graph.citation(1, 2)
  @graph.citation(2, 2)
end

Given /^a graph with profiler on$/ do
  RubyProf.start
  @graph = wikipedia_example_graph
end

Then /^the profile data should be printed$/ do
  result = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT, :min_percent=>0.1)
end

