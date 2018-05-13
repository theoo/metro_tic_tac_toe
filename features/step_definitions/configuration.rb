Given("that the playfield is a grid") do
  game = TicTacToe.new(DEFAULT_CONFIG)
  expect(game).to be_a TicTacToe
  expect(game.grid).to be_an Array
end

When("configured to any values between {int} and {int}") do |int, int2|
  config = DEFAULT_CONFIG
  @games = {}

  (int..int2).each do |i|
    config[:grid] = i
    @games[i] = TicTacToe.new(config)
  end
end

Then("the grid size should equal the square value of the configured value") do
  @games.each_pair do |size,game|
    expect(game.grid.size).to equal(size ** 2)
  end
end

Given("that {int} players are in the game") do |int|
  @game = TicTacToe.new(DEFAULT_CONFIG)
  expect(@game.players.size).to equal(int)
end

When("any of them can choose a custom symbol") do
  @game.players.each do |player|
    expect(player.symbol).to be_a String
    expect(player.symbol.size).to equal(1)
  end
end

Then("this symbol should be used on the playfield") do
  @game.moves = [[1,1]]

  @game.play do |c|
    expect(@game.grid[@game.grid_index_from_coordinate(c)]).to equal(@game.players[0].symbol)
  end
end
