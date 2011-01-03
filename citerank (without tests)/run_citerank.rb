require 'citerank'

CiteRank::CiteGraph.new("hep-th-citations", :d => "hep-th-slacdates").top 10, :display_results