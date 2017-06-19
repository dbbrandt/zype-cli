require 'yaml'

module Zype
  class Configuration
    extend Zype::Helpers

    attr_accessor :api_key
    attr_accessor :app_key
    attr_accessor :host
    attr_accessor :port
    attr_accessor :use_ssl

    class << self

      def load_yaml(yaml)
        Zype::Configuration.new.tap do |c|
          c.api_key = yaml['api_key']
          c.app_key = yaml['app_key']
          c.host = yaml['host']
          c.port = yaml['port']
          c.use_ssl = yaml['use_ssl']
        end
      end

    end

    def initialize
      @host = 'api.zype.com'
      @port = 443
      @use_ssl = true
    end

    def to_yaml
      {
        'api_key' => api_key,
        'app_key' => app_key,
        'host' => host,
        'port' => port,
        'use_ssl' => use_ssl
      }.to_yaml
    end
  end
end
