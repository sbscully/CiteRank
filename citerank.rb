require 'bigdecimal'

def cite_forward(file)
  forw = {}
  links = cite_array(file)
  links.each do |link|
    from = link[0] ; to = link[1]
    forw[from] ? forw[from] << to : forw[from] = [to]
  end
  remove_dangling_links(forw, links)
end

def back_links(file)
  back = {}
  cite_array(file).each do |link|
    from = link[0] ; to = link[1]
    back[to] ? back[to] << from : back[to] = [from]
  end
  back
end

def remove_dangling_links(hash, links)
  forw = {}
  links.each do |link|
    from = link[0] ; to = link[1]
    if hash.include? to
      forw[from] ? forw[from] << to : forw[from] = [to]
    end
  end
  forw
end

def cite_array(file)
  cite_array = []
  File.open(file) do |citation_data|
    citation_data.each do |line|
      from, to = line.split(' ')
      cite_array << [from.to_i, to.to_i]  
    end
  end
  cite_array
end

def rank_init(file)
  rank = {}
  citations = cite_forward(file)
  citations.each_key { |k| rank[k] = BigDecimal((1/citations.length).to_s) }
  rank
end

def transfer_matrix(file)
  forward = cite_forward(file)
  columns = {}
  rows = {}
  
  forward.each do |i, f|
    columns[i] = 1.0 / forward[i].count
  end
  
  forward.each do |k, v|
    v.each { |paper| rows[paper] ? rows[paper] << [k,columns[k]] : rows[paper] = [ [k,columns[k]] ] }
  end
 
  rows
end

def sparse_vector_times(value, r)
  value.reduce(0) { |tot, v| tot += (r[v[0]] || 0)*v[1] }
end

def sparse_matrix_vector_times(m, r)
  new_r = {}
  m.each do |key, value|
    new_r[key] = sparse_vector_times(value , r)
  end
  new_r
end

def rank_pages(file, diff, d)
  w = transfer_matrix(file)
  rank = rank_init(file)
  
  nodes = rank.count
  
  e = 10000
  while e.abs > diff
    new_rank = {}
    sparse_matrix_vector_times(w, rank).each { |k,v| new_rank[k] = d*v + (1-d) / nodes }
    e = (rank.values.reduce(:+) - new_rank.values.reduce(:+))
    rank = new_rank
  end
  rank
end

def top_ten
  rank = rank_pages("hep-th-citations", 1e-12, 0.5)
  values = rank.values.sort
  top10 = values.reverse[0..10]
  
  citations = back_links("hep-th-citations") 
  
  top10.each do |r|
    paper = rank.select { |k,v| v == r }[0][0]
    puts "\n #{paper.to_s} | #{normalise(r, values)*10} | #{citations[paper].count}"
  end
  nil
end

def normalise(value, set)
  max = Math.log(set.max)
  min = Math.log(set.min)
  BigDecimal( ((Math.log(value) - min) / (max - min)).to_s ).round(5).to_f 
end

def date_hash(file)
  hash = {}
  File.open(file) do |citation_data|
    citation_data.each do |line|
      paper, date = line.split(' ')
      hash[paper.to_i] = date
    end
  end
  hash
end
  
    
  
  