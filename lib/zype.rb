require 'hashie'
require 'multi_json'

#require File.join(File.dirname(__FILE__), 'zype', 'helpers')

#require File.join(File.dirname(__FILE__), 'zype', 'client')
#require File.join(File.dirname(__FILE__), 'zype', 'collection')
#require File.join(File.dirname(__FILE__), 'zype', 'configuration')
#require File.join(File.dirname(__FILE__), 'zype', 'model')

require './zype/helpers.rb'

require './zype/client.rb'
require './zype/collection.rb'
require './zype/configuration.rb'
require './zype/model.rb'



module Zype

  class << self

    # The configuration object.
    # @see Zype.configure
    def configuration
      @configuration ||= Configuration.new
    end

    # Allows configuration object to be set
    def configuration=(new_configuration)
      @configuration = new_configuration
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   Airbrake.configure do |config|
    #     config.api_key = '1234567890abcdef'
    #     config.secure  = false
    #   end
    def configure
      yield(configuration)
    end

  end
end
