# TicTacToe Challenge

Simple [TicTacToe](https://en.wikipedia.org/wiki/Tic-tac-toe) game, developed with minimal dependencies.

## specs

see `doc/challenge.pdf`

## requirements

- ruby 2
- rvm recommended

## usage

Clone and enter the repo, then type `ruby main.rb` to start the game

## configuration

Edit `config.yml` to change:

- player names and symbol
- grid size
- AI engine

## How it works

The class TicTacToe does everything, it's the game.
The folder `ai` contains pluggable AI that can be selected through `config.yml` by giving it its class name. The AI class inherit the *whole game context* through a block sending its *binding*. This way, AI code isn't mixed with the game code, but still can access all its methods and rules to actually play.

Important programing choices and decisions are described in the code itself.

## Testing

Gherkin (Cucumber) requires some dependencies that can be installed with `gem install bundle; bundle`.
To run the test, use the command `cucumber`.

Currently only challenge-specific specs have been described and tested using **rspec**.

## TODO

- develop a better AI based on [MiniMax](https://en.wikipedia.org/wiki/Minimax) or [GameTree](https://en.wikipedia.org/wiki/Game_tree) decision.
- play more
