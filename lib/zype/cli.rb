require './zype.rb'
require './zype/commands.rb'

module Zype
  class CLI
    def self.start
      Zype::Commands.start
    rescue Zype::Client::NoApiKey => e
      puts "#{e.class}: #{e.message}. Please run 'zype account:login' to configure your credentials"
    end

    def self.configure
      Zype::Auth.credentials
    end
  end
end
