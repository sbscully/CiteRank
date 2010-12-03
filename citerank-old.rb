require 'bigdecimal'

def cite_back(file)
  cite_hash file, :direction => :back
end

def cite_forward(file)
  cite_hash file, :direction => :forward
end

def cite_hash(file, options)
  cite_hash = Hash.new
  File.open(file) do |citation_data|
    citation_data.each do |line|
      k, v = line.split(' ')
      k, v = v, k if options[:direction] == :back
      cite_hash[k] ? cite_hash[k] << v : cite_hash[k] = [v]     
    end
  end
  return cite_hash
end

def page_rank(paper, back, forward, rank, d=0.15)
  sum = back[paper].inject(0) do |total, citing_paper|
    r = rank[citing_paper]
    k = forward[citing_paper].count
    total += r ? BigDecimal(r.to_s) / k : 0
  end
  
  (1-d) * sum + d / back.length
end

def page_rank_iteration(back, forward, rank)
  rank.each { |p, r| rank[p] = page_rank(p, back, forward, rank) }
end

def rank_pages(file, error)
  back = cite_back(file)
  forward = cite_forward(file)
  
  rank = {}
  back.each { |b,f| rank[b] = f.count }
  
  e = 1000
  while e > error
    new_rank = page_rank_iteration(back, forward, rank)
    e = (new_rank.values.reduce(:+) - rank.values.reduce(:+)) ; puts e
    rank = new_rank
  end
  rank
end

def top_ten
  rank_pages("hep-th-citations", 0.01).values.sort.reverse[0...10]
end 

def transfer_matrix(i, j, forward_j)
  forward_j.include? i ? 1 / BigDecimal(forward_j.count) : BigDecimal('0')
end
  
  