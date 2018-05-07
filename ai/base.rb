class Ai::Base

  #
  # Main and only method called by the game to query coordinates
  #
  #
  # @return [Array<Integer>] x,y coordinates
  #
  def get_coordinates
    raise NotImplementedError, 'you need to subclass & overload this method'
  end

end