# @author Théo Reichel

class Ai::Random < Ai::Base

  def initialize
  end

  #
  # @see base.rb
  #
  def get_coordinates
    @game_context = yield
    @grid = @game_context.eval("@grid")
    @config = @game_context.eval("@config")

    find_valid_coordinate
  end

  private

    #
    # Try to find a valid coordinate, just by pocking the grid randomly
    #
    #
    # @return [Array<Integer>] x,y valid coordinates
    #
    def find_valid_coordinate
      coordinates = nil
      while coordinates.nil?
        c = [
          SecureRandom.random_number(0..@config[:grid] - 1),
          SecureRandom.random_number(0..@config[:grid] - 1)
        ]
        coordinates = @game_context.eval("validate_coordinates('#{c.join(",")}')")
      end
      coordinates
    end

end