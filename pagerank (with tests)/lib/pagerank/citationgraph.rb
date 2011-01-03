module CiteRank
  class CitationGraph
    attr_accessor :citations
    
    def initialize options={}
      @citations = Citations.new
      @d = options[:d] || 0.85
      @accuracy = options[:accuracy] || 1e-50
    end
  
    def citation from, to
      @citations << [from, to]
    end
    
    def nodes
      @citations.flatten.uniq
    end
    
    def clear
      @citations = Citations.new
    end
    
    def rank
      @rank ||= rank!
    end
    
    def rank!
      rank_vector = RankVector.new(@citations.forward.keys)
      transfer_matrix = TransferMatrix.new(@citations.forward, @d)
      rank_vector.converge(transfer_matrix, @accuracy)
    end
  end
  
  class Citations < Array
    def forward
      forw = {}
      self.each do |link|
        from = link[0] ; to = link[1]
        forw[from] ? forw[from] << to : forw[from] = [to]
      end
      dangling_links(forw)
    end

    def backward
      back = {}
      self.each do |link|
        from = link[0] ; to = link[1]
        back[to] ? back[to] << from : back[to] = [from]
      end
      back
    end
  
    private

      def dangling_links(forw)
        from, to = [], []
        self.each do |link|
          from << link[0] ; to << link[1]
        end
        dangling_papers = (to - from).uniq
        all_papers = (from + to).uniq
        dangling_papers.each do |paper|
          forw[paper] = all_papers
        end
        forw
      end
  end
end