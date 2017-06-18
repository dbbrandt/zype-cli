require './zype.rb'
require './zype/commands.rb'
#require 'pry'
#require 'pry-byebug'

commands = Zype::Commands.new
commands.init_client
zype = commands.instance_variable_get(:@zype)
puts zype.videos.all
