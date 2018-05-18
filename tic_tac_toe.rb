# @author Théo Reichel

class TicTacToe

  require 'securerandom'

  require './ai'
  include Ai

  PlayerStruct = Struct.new(:name, :symbol)

  # For testing and AI
  attr_reader :players
  attr_accessor :config
  attr_accessor :winner
  attr_accessor :round
  attr_accessor :grid
  attr_accessor :moves

  #
  # Game constructor
  #
  # @param [Hash] config configuration
  # @param [Array] grid for a preset game
  # @param [Integer] round for a preset game
  #
  def initialize(config, grid = nil, round = 0)
    @config = config
    validate_config

    @ai = Ai.init(@config[:ai])
    @players = @config[:players].map{|p| PlayerStruct.new(*p)}.shuffle

    # x * y
    if grid
      @grid = grid
    else
      @grid = [nil] * @config[:grid] * @config[:grid]
    end

    @winner = nil

    @round = round

    # preset moves
    @moves = []
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

    puts colorize(36) { title }

    draw

    while @winner.nil?

      if current_player.name.to_s == @config[:computer_name].to_s and !simulation?
        # pass the context, some AI might require access to almost everything (including current_player's bank account)
        puts "\t #{@config[:computer_name]} (the computer) is thinking..."
        xy = @ai.get_coordinates { binding }
        cartesian_coordinates = xy[0] + 1, @config[:grid] - xy[1]
        puts "\t #{@config[:computer_name]} played #{cartesian_coordinates.join(',')}."
      else
        xy = request_coordinates(current_player)
      end

      # set symbol to corresponding grid index
      @grid[grid_index_from_coordinate(xy)] = current_player.symbol

      draw

      @winner ||= check_winner
      # check for draw
      @winner ||= "Nobody" if over?

      # Send part of the context if a block is given, for AI and testing
      yield(xy) if block_given?

      @round += 1

    end

    if @winner.is_a? PlayerStruct
      print "#{@winner.name} won!"
      puts " Congratulations!" unless @winner == @config[:computer_name]
    elsif @winner == 'Nobody'
      puts " OMG, it's a draw!"
    elsif @winner == 'Simulation'
      puts " Don't worry, it's just a simulation."
    end
    puts ""

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
    cursor = @config[:grid]
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

  def over?
    !@grid.include? nil
  end

  #
  # Draw the board, legend and rules
  #
  #
  # @param [Integer] color_code the color-code to draw the table
  #
  # @return [NilClass] nil
  #
  def draw(color_code = 37)

    pix = colorize(color_code) do
      # top frame
      str = ""
      str <<  "\t y \n"
      str <<  "\t ↓ \n"
      str << "\t   "
      str << ("-" * (@config[:grid] * 2 + 1) + "\n")
      @grid.each_with_index do |symbol, idx|

        # left frame
        if idx % @config[:grid] == 0
          line_idx = @config[:grid] - idx / (@config[:grid]) # () = ruby syntax issue in sublime text...
          str << "\t#{line_idx.to_s.ljust(2, " ")} |"
        end

        str << (symbol.nil? ? " " : symbol)
        if idx % @config[:grid] == @config[:grid] - 1
          # right frame
          str << "|\n"
        else
          # frame
          str << "|"
        end

      end

      # bottom frame
      str << "\t   "
      str << ("-" * (@config[:grid] * 2 + 1) + "\n")

      # column index
      str << "\t    "
      (@config[:grid]).times{|n| str << "#{n + 1} "}
      str << " ← x\n"
      str << " \n"
      str
    end

    puts pix

    nil
  end

  #
  # Current playing player
  #
  #
  # @return [PlayerStruct] the current player
  #
  def current_player
    turn = @round % @players.count
    @players[turn]
  end

  private

    #
    # Ask coordinate to the user
    #
    # @param [PlayerStruct] player object
    #
    # @return [Array<Integer>] coordinate to the for x,y
    #
    def request_coordinates(player)
      if simulation?
        puts "\tPlaying the preset coordinates #{@moves[0]}."
        answer = validate_coordinates(@moves.shift.join(","))

        # End the game if all preset moves have been played
        @winner = "Simulation" if @moves.empty?
      else
        ask "#{player.name} (#{player.symbol}), it's your turn. Please write coordinates to the form 'x,y': "
        answer = nil
        while answer.nil?
          answer = validate_coordinates(gets)
        end
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

        # Convert Cartesian value to the imaginary bi-dimensional array
        # This is called "imaginary" because this system is stored to uni-dimensional array (@grid), the representation
        # is used only to validate the range.
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

    #
    # Is it a real game or a simulation?
    #
    #
    # @return [Boolean] true if it's a simulation
    #
    def simulation?
      @moves.size > 0
    end

    #
    # Colorize the String returned by the block
    #
    # @param [Integer] color_code the code of the color
    #   Foreground
    #   30 = black
    #   31 = red
    #   32 = green
    #   33 = yellow
    #   34 = blue
    #   35 = magenta
    #   36 = cyan
    #   37 = gray
    #
    #   Backgrounds
    #   40 = bg_black
    #   41 = bg_red
    #   42 = bg_green
    #   43 = bg_brown
    #   44 = bg_blue
    #   45 = bg_magenta
    #   46 = bg_cyan
    #   47 = bg_gray
    #
    # @return [String] Colorized String
    #
    # @yieldreturn [String] The called block should return a String to be colorized
    def colorize(color_code, &block)
      str = yield
      if str.is_a? String
        "\e[#{color_code}m#{str}\e[0m"
      else
        raise ArgumentError, "Expect the block to return a String"
      end
    end

end

trap('INT') do
  puts ""
  puts "bye!"
  exit
end
