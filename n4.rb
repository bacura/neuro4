#! /usr/bin/ruby
# Neuro4 0.00b

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
$SIZE = 10 * 10 * 10 * 10
$DEPTH = 10
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
		puts "Creating neuro4." unless opt['quiet']
		@n4_name = ''
		@generation = 0
		@n4 = []
		@his_bit = []
		@miss_bit = []
		@exp = []

		0.upto( $DEPTH - 1 ) do |d|
			@n4[d] = []
			@his_bit[d] = []
			@miss_bit[d] = []
			@exp[d] = []
			0.upto( $DEPTH - 1 ) do |dd|
				@n4[d][dd] = []
				@his_bit[d][dd] = []
				@miss_bit[d][dd] = []
				@exp[d][dd] = []
				0.upto( $DEPTH - 1 ) do |ddd|
					@n4[d][dd][ddd] = []
					@his_bit[d][dd][ddd] = []
					@miss_bit[d][dd][ddd] = []
					@exp[d][dd][ddd] = []
					0.upto( $DEPTH ) do |dddd|
						if rand( 11 ) == 10
							@n4[d][dd][ddd][dddd] = '9999'
						else
							@n4[d][dd][ddd][dddd] = '0000'
						end
						@his_bit[d][dd][ddd][dddd] = 0
						@miss_bit[d][dd][ddd][dddd] = 0
						@exp[d][dd][ddd][dddd] = 0
					end
				end
			end
		end
		puts "Done." unless opt['quiet']
	end

	# ファイルからn4へ転写
	def trans_in( opt )
		puts "Loading neuro4." unless opt['quiet']
		f = open( opt['cube'], 'r' )
		c = -1
		f.each_line do |e|
			t = e.chomp.split( ':' )
			if c == -1
				@n4_name = t[0]
				@generation = t[1].to_i
			else
				pos = sprintf("%04d", c ).split( '' )
				@n4[pos[0].to_i][pos[1].to_i][pos[2].to_i][pos[3].to_i] = t[0]
				@miss_bit[pos[0].to_i][pos[1].to_i][pos[2].to_i][pos[3].to_i] = t[1].to_i
				@exp[pos[0].to_i][pos[1].to_i][pos[2].to_i][pos[3].to_i] = t[2].to_i
			end
			c += 1
		end
		f.close
		puts "Done." unless opt['quiet']
	end









	# 移動方向の決定
	def decide_pos( pos )
		tpos = Marshal.load( Marshal.dump( pos ))
		dir = []
		challenge_flag = true
		c = 0
		while challenge_flag
			# 仮の新しいポジションを決定する
			0.upto( 3 ) do |cc|
				dir[cc] = rand( 0..2 )
				if dir[cc] == 1
					tpos[cc] += 1
				elsif dir[cc] == 2
					tpos[cc] -= 1
				end
				tpos[cc] = 0 if tpos[cc] > 9
				tpos[cc] = 9 if tpos[cc] < 0
			end

			# 新しいポジションを調べる
			t = @n4[tpos[0]][tpos[1]][tpos[2]][tpos[3]]
			if t != '9999' and @his_bit != 1
				challenge_flag = false
			end
			return pos if c > 10

			# とりあえず通った場所に
			@miss_bit[pos[0]][pos[1]][pos[2]][pos[3]] = 1
			c += 1
		end

		@n4[pos[0]][pos[1]][pos[2]][pos[3]] = "#{dir[0]}#{dir[1]}#{dir[2]}#{dir[3]}"
		return tpos
	end





	# n4を刺激
	def stimulus( code, opt )
		puts "Stimulation neuro4." unless opt['quiet']

		# 開始位置の展開
		pos = code.split( '' )
		pos.map! do |x| x.to_i end

		until depth == 100
			# 開始位置に履歴フラグを付加
			@his_bit[pos[0]][pos[1]][pos[2]][pos[3]] = 1

			# 開始方向の展開
			dir = @n4[pos[0]][pos[1]][pos[2]][pos[3]].split( '' )
			dir.map! do |x| x.to_i end

			if dir[0] == 0 && dir[1] == 0 && dir[2] == 0 && dir[3] == 0
				#ランダム移動
				code = decide_pos( pos )
			else
				#通常移動
				@exp[pos[0]][pos[1]][pos[2]][pos[3]] += 3
				0.upto( 3 ) do |c|
					if dir[c] == 1
						pos[c] += 1
					elsif dir[c] == 2
						pos[c] -= 1
					end
					pos[c] = 0 if pos[c] > 9
					pos[c] = 9 if pos[c] < 0
				end
			end

			depth += 1
		end
		puts "Done." unless opt['quiet']
	end


	# n4からファイルへ転写
	def trans_out( opt )
		puts "Saving neuro4." unless opt['quiet']
		f = open( opt['cube'], 'w' )
		f.puts "#{opt['label']}:#{@generation}\n"

		0.upto( $DEPTH - 1 ) do |d|
			0.upto( $DEPTH - 1 ) do |dd|
				0.upto( $DEPTH - 1 ) do |ddd|
					0.upto(  $DEPTH - 1 ) do |dddd|
						f.puts "#{@n4[d][dd][ddd][dddd]}:#{@miss_bit[d][dd][ddd][dddd]}:#{@exp[d][dd][ddd][dddd]}\n"
					end
				end
			end
		end

		f.close
		puts "Done." unless opt['quiet']
	end
end

#==============================================================================
puts 'neuro4 0.00'
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


#### n4ファイルの読み込み
n4.trans_in( opt ) if File.exist?( opt['cube'] )


#### n4興奮
n4.stimulus( code, opt )
















####  n4ファイルへ書き込み
n4.trans_out( opt ) unless opt['cube'] == ''


#### 結果の出力
