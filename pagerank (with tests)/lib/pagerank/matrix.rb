module CiteRank
  class RankVector < Hash
    def initialize papers
      if papers.class == Array
        @papers = papers
        super(1.0/papers.count)
      else 
        super(papers)
      end
    end
    
    def converge matrix, accuracy
      e = 2*accuracy
      while e.abs > accuracy
        new_rank_vector = self.multiply(matrix)
        e = diff(self, new_rank_vector)
        self.replace(new_rank_vector)
      end
      self
    end
        
    def multiply matrix
      output = RankVector.new(0)
      @papers.each do |i|
		@papers.each do |j|
		  output[i]  += self[j] * matrix[ [i,j] ]
		end
      end
      output
    end
    
    def diff v1, v2
      diff = []
      v1 = v1.values.sort ; v2 = v2.values.sort
      v2.each_with_index { |e, i| diff << e - (v1[i] || 0) }
      diff.reduce(:+)
    end
      
  end
  
  class TransferMatrix < Hash
    def initialize papers, d
	  e = (1-d)/papers.count
      super(e)
      papers.each do |paper, citations|
        citations.each do |citation|
          self[[citation, paper]] = d/citations.count + e
        end
      end
    end 
  end
end







