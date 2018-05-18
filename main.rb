# @author Théo Reichel

require 'rubygems'
require 'yaml'
require './tic_tac_toe'

default_config = {
  grid: 5,
  players: {
    dave: 'X',
    frank: 'O',
    hal: '#'
  },
  computer_name: 'hal',
  ai: 'Random'
}
yaml_config = YAML.load_file('config.yaml')
config = default_config.merge(yaml_config)

game = TicTacToe.new(config)

game.play
