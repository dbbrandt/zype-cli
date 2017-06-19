require './zype.rb'
require './zype/commands.rb'
#require 'pry'
#require 'pry-byebug'

begin
commands = Zype::Commands.new
zype = commands.init_client
puts zype.videos.all
rescue ArgumentError => e
  puts "Zype Video List Exception: #{e}"
end