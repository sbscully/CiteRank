 require 'lib/citerank/citationgraph'
 require 'lib/citerank/matrix'

graph = CiteRank::CitationGraph.new

File.open("hep-th-citations") do |citation_data|
  citation_data.each do |line|
    from, to = line.split(' ')
    graph.citation from, to
  end
end

rank = graph.rank

puts rank