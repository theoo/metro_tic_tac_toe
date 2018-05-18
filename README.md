# TicTacToe Challenge

Simple [TicTacToe](https://en.wikipedia.org/wiki/Tic-tac-toe) game, developed with minimal dependencies.

## specs

see `doc/challenge.pdf`

## requirements

- ruby 2
- rvm is recommended

## usage

Clone and enter the repo, then type `ruby main.rb` to start the game

## configuration

Edit `config.yml` to change:

- player names and symbol
- grid size
- AI engine

## How it works

The class TicTacToe does everything, it's the game. I didn't build a complex OO sub-classing of Game/Playfield/Player because the logic is basic enough and I find easier to write and understand with basic objects/structures.
The folder `ai` contains pluggable AI that can be selected through `config.yml` by giving it its class name. The AI class inherit the *whole game context* through a block sending its *binding*. This way, AI code isn't mixed with the game code, but still can access all its methods and rules to actually play.

Important programing choices and decisions are described in the code itself.

## Artificial Intelligence

In this code there is yet no such thing as an optimal intelligence...
Current existing methods such as MiniMax have a limited performance on big playfield. On a 3x3 playfield with 3 different symbols, the number of possible games is 262'144 (end node leaf only).
```
4^(3 x 3) = 262'144
```
Where 4 is the number of possible symbols (for instance: X, O, # and blank), and 3*3 is the size of the board.
Any modern computer can generate this game tree with ease.

On a 4x4 playfield the number of games jumps to 4'294'967'296 and any regular computer will already start choking.
On a 10x10 playfield the number of games reaches a generous 1.60 x 10^60, or 1.6 _Novemdecillions_!
When the playfield increase so does the _game complexity_, and optimization is required. Methods like _genetic algorithms_ or _neural networks_ are more adapted to big playfield (with complex rules), like for the _Chess game_.
I believe finding the correct solution is outside of this challenge scope.

## Documentation

The code documentation can be generated using [yard](https://yardoc.org/).
To install it, type `gem install yard`, then you can generate it using `yardoc --private ./**/*.rb` and open _doc/index.html_.

## Testing

Gherkin (Cucumber) requires some dependencies that can be installed with `gem install bundle; bundle`.
To run the test, use the command `cucumber`.

Currently only challenge-specific specs have been described and tested using **rspec**.

## TODO

- play more
