require 'bigdecimal'
require 'date'

class Citations
  def initialize(file)
    @links = generate_links_array(file)
  end
  
  def forward
    forw = {}
    @links.each do |link|
      from = link[0] ; to = link[1]
      forw[from] ? forw[from] << to : forw[from] = [to]
    end
    remove_dangling_links(forw)
  end

  def backward
    back = {}
    @links.each do |link|
      from = link[0] ; to = link[1]
      back[to] ? back[to] << from : back[to] = [from]
    end
    back
  end
  
  private

  def remove_dangling_links(hash)
    forw = {}
    @links.each do |link|
      from = link[0] ; to = link[1]
      if hash.include? to
        forw[from] ? forw[from] << to : forw[from] = [to]
      end
    end
    forw
  end

  def generate_links_array(file)
    cite_array = []
    File.open(file) do |citation_data|
      citation_data.each do |line|
        from, to = line.split(' ')
        cite_array << [from.to_i, to.to_i]  
      end
    end
    cite_array
  end
end

class TransferMatrix 
  def initialize(citations_hash={})
    @matrix = Hash.new(0)
    if citations_hash
      citations_hash.each { |paper,citations| add_paper([paper, citations]) }
    end
  end
  
  def [](row, column)
    @matrix[[row, column]]
  end
  
  def add_paper(array)
    paper = array[0] ; citations = array[1]
    citations.each { |citation| @matrix[[paper, citation]] = 1.0 / citations.count }
  end
  
  alias << add_paper

  def multiply_rank_vector(rank_vector)
    output_vector = Hash.new(0)
    @matrix.each do |i, v|
      output_vector[i[1]]  += (rank_vector[i[0]]) * v
    end
    RankVector.new(:values => output_vector)
  end
end

class RankVector
  def initialize(options={})
    @vector = options[:values] || Hash.new(0)
    default_values(options[:default_values]) if options[:default_values]
  end
  
  def default_values(citations_hash)
    citations_hash.each_key do |k| 
      @vector[k] = BigDecimal('1')/citations_hash.length
    end
  end
  
  def sum
    @vector.values.reduce(:+)
  end
  
  def sort
    sorted = []
    @vector.each { |k,v| sorted << [v,k] }
    sorted.sort.reverse.map { |a| a[0], a[1] = a[1], a[0] }
  end
  
  def normalise
    normalised = Hash.new(0)
    max, min = Math.log(@vector.values.max), Math.log(@vector.values.min)
    @vector.each { |k,v| normalised[k] = ( Math.log(v) - min ) / ( max - min ) }
    RankVector.new(:values => normalised)
  end
  
  def add_paper(paper)
    @vector[paper] ||= BigDecimal('1')/@vector.length
  end
  
  alias << add_paper
  
  def [](index)
    @vector[index]
  end
  
  def []=(index, value)
    @vector[index] = value
  end
  
  def each(&block)
    @vector.each(&block)
  end
  
  def length
    @vector.length
  end
end

class CiteGraph
  def initialize(file, options={})
    @citations = Citations.new(file)
    @accuracy = options[:accuracy] || 1e-10
    @d = get_d(options[:d])
  end
  
  def rank
    @rank ||= rank!
  end
  
  def rank!
    transfer_matrix = TransferMatrix.new(@citations.forward)
    rank_vector = RankVector.new(:default_values => @citations.forward)
    
    e = 1
    while e.abs > @accuracy
      new_rank_vector = transfer_matrix.multiply_rank_vector(rank_vector)
      new_rank_vector.each do |k,v| 
        new_rank_vector[k] = @d[k]*v + (1-@d[k]) / rank_vector.length
      end
      e = (rank_vector.sum - new_rank_vector.sum)
      rank_vector = new_rank_vector
    end
    @rank = rank_vector
  end
  
  def top(number, display=false)
    top = rank.normalise.sort[0..number]
    cited_by = @citations.backward
    if display
      top.each { |r| puts "\n #{r[0].to_s} | #{r[1]*10} | #{cited_by[r[0]].count} " }
    end
    top
  end
  
  private
  
  def get_d(options_d)
    if options_d.class == String
           d_hash = Hash.new(0.5)
           age_hash(options_d).each { |k,v| d_hash[k] = Math::E**(-v/380) }
           d_hash
         else
           Hash.new(options_d || 0.5)
         end
  end
  
  def age_hash(file)
    age_hash = {}
    today = Date.parse(Time.now.to_s)
    date_hash(file).each { |k,v| age_hash[k] = (today - v).to_f }
    age_hash
  end
  
  def date_hash(file)
    hash = {}
    File.open(file) do |citation_data|
      citation_data.each do |line|
        paper, date = line.split(' ')
        hash[paper.to_i] = Date.strptime(date, "%Y-%m-%d")
      end
    end
    hash
  end
end



  
    
  
  