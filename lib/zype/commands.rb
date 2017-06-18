require 'hirb'
require "thor.rb"
require './zype/auth'
require "./zype/commands/account.rb"
require "./zype/commands/category.rb"
require "./zype/commands/consumer.rb"
require "./zype/commands/device.rb"
require "./zype/commands/device_category.rb"
require "./zype/commands/plan.rb"
require "./zype/commands/playlist.rb"
require "./zype/commands/revenue_model.rb"
require "./zype/commands/subscription.rb"
require "./zype/commands/video.rb"
require "./zype/commands/zobject.rb"
require "./zype/commands/zobject_type.rb"
require "./zype/progress_bar.rb"


module Zype
  class Commands < Thor
    extend Hirb::Console

    no_commands do
      def init_client
        Zype::Auth.load_configuration
        @zype = Zype::Client.new
      end
    end

  end
end
