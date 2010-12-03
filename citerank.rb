require 'bigdecimal'

def cite_array(file)
  cite_array = []
  File.open(file) do |citation_data|
    citation_data.each do |line|
      cite_array << line.split(' ').collect { |a| a.to_i }
    end
  end
  cite_array
end

def cite_to(file)
  forw = {}
  links = cite_array(file)
  links.each do |link|
    from = link[0] ; to = link[1]
    append_or_create(forw, from, to)
  end
  remove_dangling_links(forw, links)
end

def cited_by(file)
  back = {}
  cite_array(file).each do |link|
    from = link[0] ; to = link[1]
    append_or_create(back, to, from)
  end
  back
end

def remove_dangling_links(hash, links)
  forw = {}
  links.each do |link|
    from = link[0] ; to = link[1]
    if hash.include? to
      append_or_create(forw, from, to)
    end
  end
  forw
end

def append_or_create(hash, key, value)
  hash[key] ? hash[key] << [value] : hash[key] = [ [value] ]
end

def rank_init(file)
  rank = {}
  cite_to(file).each_key { |k| rank[k] = BigDecimal(rand.to_s) }
  rank
end

def transfer_matrix(file)
  forward = cite_to(file)
  columns = {}
  rows = {}
  
  forward.each do |i, f|
    columns[i] = 1.0 / forward[i].count
  end
  
  forward.each do |k, v|
    v.each do |paper| 
      append_or_create(rows, paper, [k,columns[k]]) 
    end
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

  e = diff + 1
  while e.abs > diff
    new_rank = {}
    sparse_matrix_vector_times(w, rank).each do |k,v| 
      new_rank[k] = (1-d)*v + d / rank.count
    end
    e = (rank.values.reduce(:+) - new_rank.values.reduce(:+))
    rank = new_rank
  end
  rank
end

def top_ten
  rank = rank_pages("hep-th-citations", 1e-12, 0.48)
  citations = cited_by("hep-th-citations") 
  top10 = rank.values.sort.reverse[0..10]
  
  top10.each do |r|
    paper = rank.select { |k,v| v == r }[0][0]
    puts "\n #{paper.to_s} | #{normalise(r, values)*10} | #{citations[paper].count}"
  end
  nil
end

def normalise(value, set)
  max = set.max ; min = set.min
  BigDecimal( ((value - min) / (max - min)).to_s ).round(5).to_f 
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
  
  