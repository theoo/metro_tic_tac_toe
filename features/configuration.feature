@todo

Feature: Tic Tac Toe configuration

  Players should be able to adapt few settings of the game like:
  - the playfield size
  - players symbols

  TODO: describe validations

  Scenario: Configuring the playfield
    Given that the playfield is a grid
    When configured to any values between 3 and 10
    Then the grid size should equal the square value of the configured value

  Scenario: Configuring symbols
    Given that 3 players are in the game
    When any of them can choose a custom symbol
    Then this symbol should be used on the playfield
