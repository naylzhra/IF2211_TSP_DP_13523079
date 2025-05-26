class TSPSolver
  def initialize(distance_matrix)
    @distance_matrix = distance_matrix
    @n = distance_matrix.length
    @memo = {}
    
    validate_input
  end

  def solve
    puts "Jumlah kota: #{@n}"
    puts "Matrix jarak:"
    display_matrix
    
    start_time = Time.now
    result = calc
    end_time = Time.now
    
  puts "\n===== RESULT ====="
    puts "Jarak minimum: #{result[:distance]}"
    puts "Path optimal: #{result[:path].join(' -> ')}"
    puts "Waktu eksekusi: #{((end_time - start_time) * 1000).round(2)} ms"
    puts "Jumlah state yang dikunjungi: #{@memo.size}"
    result
  end

  def calc
    return { distance: 0, path: [0] } if @n <= 1
    
    min_cost = tsp(1, 0)
    path = construct_path
    
    {
      distance: min_cost,
      path: path
    }
  end
  

  
  private
  
  def validate_input
    raise ArgumentError, "Matrix harus berupa array 2D" unless @distance_matrix.is_a?(Array)
    raise ArgumentError, "Matrix tidak boleh kosong" if @n == 0
    @distance_matrix.each_with_index do |row, i|
      raise ArgumentError, "Matrix harus berbentuk persegi" unless row.length == @n
      raise ArgumentError, "Jarak diagonal harus 0" unless row[i] == 0
    end
  end

  def tsp(mask, pos)
    if mask == (1 << @n) - 1
      return @distance_matrix[pos][0]
    end
    
    key = [mask, pos]
    return @memo[key] if @memo.key?(key)
    
    min_cost = Float::INFINITY
    
    (0...@n).each do |next_city|
      next if (mask & (1 << next_city)) != 0
      
      new_mask = mask | (1 << next_city)
      cost= @distance_matrix[pos][next_city] + tsp(new_mask, next_city)
      min_cost = [min_cost,cost].min
    end
    
    @memo[key] = min_cost
    min_cost
  end
  
  def construct_path
    path = [0]
    mask = 1
    pos = 0
    
    while mask != (1 << @n) - 1
      next_city = nil
      min_cost = Float::INFINITY
      (0...@n).each do |city|
        next if (mask & (1 << city)) != 0
        new_mask = mask | (1 << city)
        cost = @distance_matrix[pos][city] + (@memo[[new_mask, city]] || tsp(new_mask, city))
        if cost < min_cost
          min_cost = cost
          next_city = city
        end
      end

      path << next_city
      mask |= (1 << next_city)
      pos = next_city
    end
    path << 0
    path
  end
  
  def display_matrix
    @distance_matrix.each_with_index do |row, i|
      formatted_row = row.map { |val| val.to_s.rjust(3) }.join(' ')
      puts "  #{i}: [#{formatted_row}]"
    end
  end
end

def read_matrix_from_file(filename)
  begin
    raw_lines = File.readlines(filename)
    lines = []
    raw_lines.each_with_index do |raw_line, line_num|
      cleaned_line = raw_line.rstrip
      next if cleaned_line.empty?
      if cleaned_line.match?(/\s{2,}/)
        raise "Baris #{line_num + 1} mengandung multiple spaces berturut-turut: '#{raw_line.chomp}'"
      end
      if cleaned_line.start_with?(' ')
        raise "Baris #{line_num + 1} dimulai dengan spasi: '#{raw_line.chomp}'"
      end
      if cleaned_line.end_with?(' ')
        raise "Baris #{line_num + 1} diakhiri dengan spasi: '#{raw_line.chomp}'"
      end
      lines << cleaned_line
    end
    
    if lines.empty?
      raise "File kosong atau hanya berisi baris kosong"
    end
  
    n = lines.length
    matrix = []
    lines.each_with_index do |line, i|
      elements = line.split(' ')
      row = []
      elements.each_with_index do |element, j|
        unless element.match?(/^-?\d+$/)
          raise "Baris #{i + 1}, kolom #{j + 1}: '#{element}' bukan integer valid"
        end
        row << element.to_i
      end
      if row.length != n
        raise "Baris #{i + 1} memiliki #{row.length} elemen, seharusnya #{n}"
      end
      matrix << row
    end
    matrix 
  rescue Errno::ENOENT
    puts "ERROR: File '#{filename}' tidak ditemukan!"
    exit(1)
  rescue => e
    puts "ERROR: #{e.message}"
    exit(1)
  end
end

def main
  puts "=" * 60
  puts "TRAVELING SALESMAN PROBLEM SOLVER".center(60)
  puts "Dynamic Programming".center(60)
  puts "=" * 60
  
  print "Masukkan nama file input (contoh: input.txt): "
  filename = gets.chomp.strip
  
  if filename.empty?
    puts "ERROR: Nama file tidak boleh kosong!"
    exit(1)
  end
  
  matrix = read_matrix_from_file("test/" + filename)
  solver = TSPSolver.new(matrix)
  solver.solve
end

if __FILE__ == $0
  main
end