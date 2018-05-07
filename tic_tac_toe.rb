class TicTacToe

  require 'securerandom'

  require './ai'
  include Ai

  PlayerStruct = Struct.new(:name, :symbol)

  def initialize(config)
    @config = config
    validate_config

    @ai = Ai.init(@config[:ai])
    @players = @config[:players].map{|p| PlayerStruct.new(*p)}

    # x * y
    @grid = [nil] * @config[:grid] * @config[:grid]

    @winner = nil
    @rounds = 0
  end

  #
  # Entry point, play to the game
  #
  #
  # @return [NilClass] exits gracefully after a player won
  #
  def play

    title = <<-EOT

         *   )           *   )             *   )
       ` )  /( (       ` )  /(    )      ` )  /(       (
        ( )(_)))\\   (   ( )(_))( /(   (   ( )(_))(    ))\\
       (_(_())((_)  )\\ (_(_()) )(_))  )\\ (_(_()) )\\  /((_)
       |_   _| (_) ((_)|_   _|((_)_  ((_)|_   _|((_)(_))
         | |   | |/ _|   | |  / _` |/ _|   | | / _ \\/ -_)
         |_|   |_|\\__|   |_|  \\__,_|\\__|   |_| \\___/\\___|

         TicTacToe Challenge for Metronom
         Théo Reichel - mai 6, 2018

    EOT

    puts title

    draw

    turn = 0

    while @winner.nil?

      player = @players[turn]

      xy = if player.name.to_s == @config[:computer_name].to_s
        # pass the context, some AI might require access to almost everything (including player's bank account)
        @ai.get_coordinates { binding }
      else
        request_coordinates(player)
      end

      # set symbol to corresponding grid index
      @grid[grid_index_from_coordinate(xy)] = player.symbol

      draw

      @winner = check_winner

      @rounds += 1
      turn = (turn < @players.count - 1 ? turn + 1 : 0)

      # check for draw
      @winner = "Nobody" unless @grid.include? nil

    end

    if @winner.is_a? PlayerStruct
      print "#{@winner.name} won!"
      puts " Congratulations!" unless @winner == @config[:computer_name]
    else
      puts " OMG, it's a draw!"
    end
    puts ""

  end

  private

    #
    # Draw the board, legend and rules
    #
    # @return [NilClass] nil
    #
    def draw

      # top frame
      puts  "\t y "
      puts  "\t ↓ "
      print "\t   "
      puts "-" * (@config[:grid] * 2 + 1)
      @grid.each_with_index do |symbol, idx|

        # left frame
        if idx % @config[:grid] == 0
          line_idx = @config[:grid] - idx / (@config[:grid]) # () = ruby syntax issue in sublime text...
          print "\t#{line_idx.to_s.ljust(2, " ")} |"
        end

        print symbol.nil? ? " " : symbol
        if idx % @config[:grid] == @config[:grid] - 1
          # right frame
          puts "|"
        else
          # frame
          print "|"
        end

      end

      # bottom frame
      print "\t   "
      puts "-" * (@config[:grid] * 2 + 1)

      # column index
      print "\t    "
      (@config[:grid]).times{|n| print "#{n + 1} "}
      puts " ← x"
      puts " "

      nil
    end

    #
    # Ask coordinate to the user
    #
    # @param [PlayerStruct] player object
    #
    # @return [Array<Integer>] coordinate to the for x,y
    #
    def request_coordinates(player)
      ask "#{player.name} (#{player.symbol}), it's your turn. Please write coordinates to the form 'x,y': "
      answer = nil
      while answer.nil?
        answer = validate_coordinates(gets)
      end

      answer
    end

    #
    # Validate a set of coordinates
    #
    # @param [String] input
    #
    # @return [Array<Integer>, NilClass] x, y values in an array if valid, nil if not valid
    #
    def validate_coordinates(input)
      c = nil
      begin
        c = input.match(/\d+,\d+/).to_s
        c = c.strip.split(",").map{|n| n.strip.to_i}
      rescue
        c = nil
      end

      if c and c.size == 2

        # convert answer to the board world
        c = [
          c[0] - 1,
          @config[:grid] - c[1]
        ]

        # ensure coordinates are in range
        if (0..@config[:grid]).include?(c[0]) and (0..@config[:grid]).include?(c[1])

          # ensure cell is not already taken
          if @grid[grid_index_from_coordinate(c)].nil?
            c
          else
            ask "This cell is already taken, choose another: "
          end

        else
          ask "Theses coordinates are not in range. min: 1, max: #{@config[:grid]}: "
        end

      else
        ask "Please provide two digits in the range from 1 to #{@config[:grid]} and separated by a coma.\nTry again: "
      end
    end

    #
    # Check rows, columns and the two diagonals for a wining symbol
    #
    #
    # @return [PlayerStruct, NilClass] player object if there is a winner, otherwise nil
    #
    def check_winner
      all_symbols = [@players.map(&:symbol), nil].flatten

      # check horizontals
      matrix = @grid.each_slice(@config[:grid]).to_a
      player = count_row_symbols matrix

      # check verticals
      player ||= count_row_symbols matrix.transpose

      # check diagonals
      # /
      cursor = 5
      slash = matrix.map {|row| cursor -= 1; row[cursor]}
      slash.uniq!
      player ||= get_player_from_symbol(slash.first) if slash.size == 1 and !slash.first.nil?

      # \
      cursor = -1
      anti_slash = matrix.map {|row| cursor += 1; row[cursor]}
      anti_slash.uniq!
      player ||= get_player_from_symbol(anti_slash.first) if anti_slash.size == 1 and !anti_slash.first.nil?

      player
    end

    #
    # Check for rows full of an unique symbol
    #
    # @param [Array<String,NilClass>] matrix bi dimensional array
    #
    # @return [PlayerStruct, NilClass] player object if at least a row is completed, otherwise nil
    #
    def count_row_symbols(matrix)
      matrix.each do |row|
        next if row.uniq.first.nil?
        if row.uniq.size == 1
          return get_player_from_symbol(row.first)
        end
      end
      nil
    end

    #
    # Converter from Cartesian plane to array index
    #
    # @param [Array<Integer>] xy Cartesian values
    #
    # @return [Integer] grid index value
    #
    def grid_index_from_coordinate(xy)
      xy[0] + xy[1] * @config[:grid]
    end

    #
    # Find player object based on her/his symbol
    #
    # @param [String] symbol a char
    #
    # @return [PlayerStruct, NilClass] player object corresponding, or nil if none
    #
    def get_player_from_symbol(symbol)
      @players.select{|p| p.symbol == symbol}.first
    end

    #
    # Validate YAML config
    #
    #
    # @return [NilClass] nil if valid (passes)
    #
    def validate_config

      msg = []

      # required keys are present
      [:grid, :players, :computer_name, :ai].each do |k|
        msg << ":#{k} is missing in config" unless @config.keys.include? k
      end

      # grid range
      unless (3..10).include? @config[:grid]
        msg << ":grid should be in the range from 3 to 10"
      end

      # count and structure of players list
      if @config[:players].size < 2
        msg << ":players list should contains at least 2 players"
      else
        unless @config[:players].is_a? Hash
          msg << ":players should be a hash of players/symbol"
        end

        @config[:players].each do |p,s|
          msg << ":players symbol should be exactly one char" unless s.size == 1
        end
      end

      # computer name exists
      unless @config[:players].include? @config[:computer_name].to_sym
        msg << ":computer_name should be defined in :players list"
      end

      # ai name is valid
      begin
        Object.const_get("Ai::#{@config[:ai]}").new
      rescue
        msg << ":ai name is not valid"
      end

      if msg.size > 0
        raise ArgumentError, "Invalid config: #{msg.join(', ')}".inspect
      end

    end

    #
    # Print with a padding
    #
    # @param [String] txt the text
    #
    # @return [NilClass] nil
    #
    def ask(txt)
      print "\t#{txt}"
    end

end

trap('INT') do
  puts ""
  puts "bye!"
  exit
end
