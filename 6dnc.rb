#! /usr/bin/ruby
# 6D neuron cube 0.00b

#Bacura KYOTO Lab
#Saga Ukyo-ku Kyoto, JAPAN
#http://bi.bacura.jp
#yoshiyama@bacura.jp

#==============================================================================
#CHANGE LOG
#==============================================================================
#20170312, 0.00b, Start


#==============================================================================
#LIBRARY
#==============================================================================


#==============================================================================
#STATIC
#==============================================================================


#==============================================================================
#DEFINITION
#==============================================================================
#### Option process
def option( argv )
	opt = Hash['cube' => '', 'DEBUG' => false, 'Q' => false]
	non_opt = []

	c = 0
	argv.size.times do
		case argv[c]
		when '-c'
			opt['cube'] = argv[c + 1]
      c += 1
		when '-DEBUG'
			opt['debug'] = true
		when '-Q'
			opt['quiet'] = true
		else
			non_opt << argv[c]
		end
		c += 1
		break if c > argv.size - 1
	end

	if non_opt.size != 1
		STDERR.puts "6-dimensional neuron cube 0.00b by Bacura KYOTO Lab"
		STDERR.puts "6dnc.rb <option> 5 digit code"
		STDERR.puts "-c neuron cube file"
		STDERR.puts "-Q quiet mode"
#		exit(10)
	end

  return opt, non_opt
end


#### Error message & exit
def error_msg( message )
	STDERR.puts message
	exit(10)
end


####
def dim_six( t )
	return t[0].to_i, t[1].to_i, t[2].to_i, t[3].to_i, t[4].to_i, t[5].to_i
end


####
def pos_move( code, posa )
	d = 0
  code.chars do |ch|
    case ch.to_i
    when 1
      posa[d] += 1
      posa[d] = 9 if posa[d] > 9 && d == 9
      posa[d] = 0 if posa[d] > 9
    when 2
      posa[d] -= 1
      posa[d] = 0 if posa[d] < 0 && d == 0
      posa[d] = 9 if posa[d] < 0
    end
		d += 1
		d = 0 if d == 6
  end

	return posa
end



#==============================================================================
puts '6-dimensional neuron cube 0.00'
#==============================================================================
opt, non_opt = option( ARGV )
if /\d\d\d\d\d/ =~ non_opt[0]
	code = '0' + non_opt[0].chomp
else
	code = '000000'
end

####  Maikng new neuron cube
unless File.exist?( opt['cube'] )
  puts "Making a new neuron cube, #{opt['cube']}." unless opt['quiet']
  f = open( opt['cube'], 'w' )
	f.puts "#{opt['cube']}:0\n"
  for i in 0..999999 do
    f.puts "000000:0"
  end
  puts "Done." unless opt['quiet']
  f.close
end


####
puts "Creating neuro cube space." unless opt['quiet']
nc = []
for i in 0..9 do
  nc[i] = []
  for j in 0..9 do
    nc[i][j] = []
    for k in 0..9 do
      nc[i][j][k] = []
      for l in 0..9 do
        nc[i][j][k][l] = []
        for m in 0..9 do
          nc[i][j][k][l][m] = []
        end
      end
    end
  end
end
puts "Done." unless opt['quiet']


####  Checking neuron cube fule
unless File.exist?( opt['cube'] )
  STDERR.puts "Error. No such a file, #{opt['cube']}"
  exit(9)
end

puts "Loading Neuro cube." unless opt['quiet']
path_flag = []
memory = []
f = open( opt['cube'], 'r' )
c = 0
header = true
f.each_line do |e|
	if header
		t = e.chomp.split( ':' )
		@name = t[0]
		@generation = t[1].to_i
		header = false
	else
  	cm = e.chomp.split( ':' )
  	c7 = "%06d" % c.to_s
  	t = c7.split('')
		d1, d2, d3, d4, d5, d6 = dim_six( t )
  	nc[d1][d2][d3][d4][d5][d6] = cm[0]
  	memory[c] = cm[1].to_i
  	path_flag[c] = false
  	c += 1
	end
end
f.close
puts "Done." unless opt['quiet']


####
trace = []
posa = []
modify = false
a = code.split( '' )
for i in 0..5 do posa[i] = a[i].to_i end
puts "Recalling memory" unless opt['quiet']
until posa[0].to_i == 9
	d1, d2, d3, d4, d5, d6 = dim_six( posa )
	posi = posa.join( '' ).to_i
	trace << posi

	####	Loop process
  if path_flag[posi]
    print "Loop\z" unless opt['quiet']
    while path_flag[posi] do
      path_flag[posi] = false
      memory[posi] = 0
      t = nc[d1][d2][d3][d4][d5][d6]
      nc[d1][d2][d3][d4][d5][d6] = '000000'
			posa = pos_move( t, posa )
			d1, d2, d3, d4, d5, d6 = dim_six( posa )
      posi = posa.join('').to_i
    end
  end

	#### New memory process
	if memory[posi] == 0
		modify = true
  	print "New memory\z" unless opt['quiet']
    new_code = []
    for i in 0..5
      r = rand( 100 )
      if r <= 9
        new_code[i] = 1
      elsif r <= 19
        new_code[i] = 2
      elsif r >= 95 && i == 0
        new_code[i] = 1
      else
        new_code[i] = 0
      end
    end
    nc[d1][d2][d3][d4][d5][d6] = new_code.join('')
  end

	#### Tracing process
  memory[posi] += 1 if memory[posi] < 9
  path_flag[posi] = true
  t = nc[d1][d2][d3][d4][d5][d6]
	posa = pos_move( t, posa )
	print "Depth:#{posa[0]} / Step:#{trace.size}\r" unless opt['quiet']
end


####
if modify
	puts "Transfering memory into the euro cube." unless opt['quiet']
	f = open( opt['cube'], 'w' )
	@generation += 1
	f.puts "#{@name}:#{@generation}\n"
	for i in 0..999999
		i6 = "%06d" % i
		t = i6.split('')
		d1, d2, d3, d4, d5, d6 = dim_six( t )
  	f.puts "#{nc[d1][d2][d3][d4][d5][d6]}:#{memory[i]}\n"
	end
	f.close
	puts "Done." unless opt['quiet']
end
puts "\n"


####
puts trace.pop.to_s.slice( 1..5 )
puts '(^q^)' unless opt['quiet']
