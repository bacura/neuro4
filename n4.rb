#! /usr/bin/ruby
# neuron4 0.00b

#Bacura KYOTO Lab
#Saga Ukyo-ku Kyoto, JAPAN
#yoshiyama@bacura.jp

#==============================================================================
#CHANGE LOG
#==============================================================================
#20181012, 0.00b, Start


#==============================================================================
#LIBRARY
#==============================================================================


#==============================================================================
#STATIC
#==============================================================================
$SIZE = 9* 9 * 9 * 9
$DEPTH =9
$MAX_GENERATION = 999

#==============================================================================
#DEFINITION
#==============================================================================
#### Option process
def option( argv )
	opt = Hash['cube' => '', 'label' => '', 'loop' => 1, 'wither' => false, 'DEBUG' => false, 'quiet' => false]
	non_opt = []

	c = 0
	argv.size.times do
		case argv[c]
		when '-n'
			opt['cube'] = argv[c + 1]
      c += 1
		when '-l'
			opt['label'] = argv[c + 1]
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
#		STDERR.puts "n4.rb <option> 3 digit code"
#		STDERR.puts "-c neuron cube file"
#		STDERR.puts "-Q quiet mode"
#		exit(10)
	end

  return opt, non_opt
end


#### Error message & exit
def error_msg( message )
	STDERR.puts message
	exit(10)
end


#### n4
class Neuron

	# n4配列の作成
	def initialize( opt )
		puts "Creating new n4 sphere." unless opt['quiet']
		@n4_name = ''
		@generation = 0
		@n4 = []
		@his_bit = []
		@miss_bit = []
		@level = []

		0.upto( 8 ) do |d|
			@n4[d] = []
			0.upto( 8 ) do |dd|
				@n4[d][dd] = []
				0.upto( 8 ) do |ddd|
					@n4[d][dd][ddd] = []
					0.upto( 8 ) do |dddd|
						if rand( 10 ) == 9
							@n4[d][dd][ddd][dddd] = 9
						else
							@n4[d][dd][ddd][dddd] = 0
						end
						@his_bit << 0
						@miss_bit << 0
						@level << 0
					end
				end
			end
		end
		puts "Done." unless opt['quiet']
	end

	# ファイルからn4へ転写
	def trans_in( opt )
		puts "Loading neuro4 cell." unless opt['quiet']
		f = open( opt['cube'], 'r' )
		c = -1
		f.each_line do |e|
			t = e.chomp.split( ':' )
			if c == -1
				@n4_name = t[0]
				@generation = t[1].to_i
			else
				pos9 = sprintf("%04d", c.to_s( 9 )).split( '' )
				@n4[pos9[0].to_i][pos9[1].to_i][pos9[2].to_i][pos9[3].to_i] = t[0]
				@his_bit[c] = t[1]
				@miss_bit[c] = t[2]
				@level[c] = t[3].to_i
			end
			c += 1
		end
		f.close
		puts "Done." unless opt['quiet']
	end


	# n4からファイルへ転写
	def trans_out( opt )
		puts "Saving neuro4 cell." unless opt['quiet']
		f = open( opt['cube'], 'w' )
		f.puts "#{opt['label']}:#{@generation}\n"

		c = 0
		0.upto( 8 ) do |d|
			0.upto( 8 ) do |dd|
				0.upto( 8 ) do |ddd|
					0.upto( 8 ) do |dddd|
						f.puts "#{@n4[d][dd][ddd][dddd]}:#{@his_bit[c]}:#{@miss_bit[c]}:#{@level[c]}\n"
						c += 1
					end
				end
			end
		end

		f.close
		puts "Done." unless opt['quiet']
	end
end

#==============================================================================
puts 'neuron4 0.00'
#==============================================================================

opt, non_opt = option( ARGV )

#### コードの生成
if /\d\d\d\d/ =~ non_opt[0]
	code = non_opt[0].chomp
else
	code = '0000'
end
p opt if opt['debug']
p non_opt if opt['debug']


#### n4配列の作成
n4 = Neuron.new( opt )


####  n4ファイルの読み込み
n4.trans_in( opt ) if File.exist?( opt['cube'] )


####  n4ファイルへ書き込み
n4.trans_out( opt ) unless opt['cube'] == ''




#### 結果の出力
