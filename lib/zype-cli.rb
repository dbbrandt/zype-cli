require './zype.rb'
require './zype/commands.rb'
#require 'pry'
#require 'pry-byebug'

commands = Zype::Commands.new
zype = commands.init_client
puts zype.videos.all
