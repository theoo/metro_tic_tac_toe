@todo

Feature: Tic Tac Toe custom rules

  The game is based on the original rules described on https://en.wikipedia.org/wiki/Tic-tac-toe
  with the following twists:
  - the grid is configurable between 3x3 an 10x10 cells
  - it takes 3 players to play against each other, this including an Artificial Intelligence

  This behavior test checks only the variation described in the challenge, not all Tic Tac Toe rules.
  TODO: describe Tic Tac Toe elementary rules
  TODO: describe validations

  Scenario: The first user to play is randomly selected
    Given it's a new game
    Then a random player should start

  Scenario: After a correct move, the playfield is updated
    Given a player played
    When his input is valid
    Then the playfield is updated
