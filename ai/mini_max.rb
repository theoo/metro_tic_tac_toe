class Ai::MiniMax < Ai::Base

  def initialize
    # raise ArgumentError, "not yet implemented"
  end

  #
  # @see base.rb
  #
  def get_coordinates
    @game_context = yield
    game = @game_context.receiver
    # @grid = @game_context.receiver.grid
    # @config = @game_context.receiver.config
    @ai = game.players.select{|p| p.name == game.config[:computer_name].to_sym }.first

    if game.grid.uniq.size == 1
      # Set a random coordinate if AI is the first to play
      coordinates = [
        SecureRandom.random_number(0..game.config[:grid] - 1),
        SecureRandom.random_number(0..game.config[:grid] - 1)
      ]
    else
      @time = Time.now.to_i
      @best_move = nil
      @worst_move = nil
      scores = minimax(TicTacToe.new(game.config.dup, game.grid.dup, game.round))
      @best_move ||= @worst_move
      @best_move ||= game.grid.index(nil) # AI is losing, but not exactly yet

      # Convert grid index to imaginary bi-dimensional array (@see tic_tac_toe#validate_coordinates)
      coordinates = [
        @best_move % game.config[:grid],
        @best_move / game.config[:grid]
      ]
    end

    coordinates
  end

  private

    #
    # Explore the whole game tree scores in a recursion
    #   both @best_more and @worst_move are required at an instance level.
    #   This method won't work for large game tree (more than 3x3) and therefore is timed using the @time variable to
    #   5 seconds, and the recursion stopped after this delay - returning only 0 scores which means no winner/looser.
    #
    # @param [TicTacToe] game instance
    #
    # @return [Integer] last score (not the best)
    #
    def minimax(game)

      s = score(game)
      # return the value if there is a winner or if the game is a draw
      return s if s != 0 or game.over?

      # initialize decision arrays
      scores = []
      moves = []

      # Populate arrays
      game.grid.each_with_index do |cell, pos|
        # if nil then the cell is available to play
        if cell.nil?
          possible_game = TicTacToe.new(game.config.dup, game.grid.dup, game.round + 1)
          possible_game.grid[pos] = possible_game.current_player.symbol

          # possible_game.draw(31) if possible_game.check_winner == @ai

          # Limit the calculation to 5 seconds until the AI is optimized.
          # Ways to improve with the current algorithm:
          # - check scores for all cells at the round level before descending in a branch of the game tree
          # - use threads (won't drastically improve timing)
          if Time.now.to_i - @time < 5 # seconds
            scores << minimax(possible_game)
          else
            scores << 0
          end
          moves  << pos
        end
      end

      if game.current_player == @ai
        # This is the max calculation
        max_score_index = scores.each_with_index.max[1]
        @best_move = moves[max_score_index]
        scores[max_score_index]
      else
        # This is the min calculation
        min_score_index = scores.each_with_index.min[1]
        @worst_move = moves[min_score_index]
        scores[min_score_index]
      end

    end

    def score(game)
      winner = game.check_winner

      if winner == game.current_player
        # AI
        1
      elsif winner
        # someone else is winning
        -1
      else
        0
      end

    end

end