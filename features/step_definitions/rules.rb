Given("it's a new game") do
  @games = []
  10.times do
    @games << TicTacToe.new(DEFAULT_CONFIG)
  end
end

Then("a random player should start") do
  first_players = @games.map {|game| game.players.first }
  expect(first_players.uniq.count).to be > 1
end

Given("a player played") do
  @game = TicTacToe.new(DEFAULT_CONFIG)
  @game.moves = [[1,1]]
  @game.play
end

When("his input is valid") do
  @game.round == 1
end

Then("the playfield is updated") do
  expect(@game.grid.uniq.size).to be > 1
  expect(@game.grid).to include(@game.players.first.symbol)
end
