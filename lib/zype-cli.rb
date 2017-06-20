require './zype.rb'
require './zype/commands.rb'
#require 'pry'
#require 'pry-byebug'


=begin
begin
  commands = Zype::Commands.new
  zype = commands.init_client
  videos = zype.videos.all
  videos.each do |v|
    puts v
  end
rescue ArgumentError => e
  puts "Zype Video List Exception: #{e}"
end
=end

begin
  commands = Zype::Commands.new
  zype = commands.init_client
  result = zype.login({username: "test@test.com", password: "password"})
  puts result.inspect
rescue ArgumentError => e
  puts "Zype Video List Exception: #{e}"
end
