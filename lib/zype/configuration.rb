require 'yaml'

module Zype
  class Configuration
    extend Zype::Helpers

    attr_accessor :api_key
    attr_accessor :app_key
    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :host
    attr_accessor :oauth_host
    attr_accessor :port
    attr_accessor :use_ssl

    class << self

      def load_yaml(yaml)
        Zype::Configuration.new.tap do |c|
          c.api_key = yaml['api_key']
          c.app_key = yaml['app_key']
          c.client_id = yaml['client_id']
          c.client_secret = yaml['client_secret']
          c.host = yaml['host']
          c.oauth_host = yaml['oauth_host']
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
        'client_id' => client_id,
        'client_secret' => client_secret,
        'host' => host,
        'ouath_host' => oauth_host,
        'port' => port,
        'use_ssl' => use_ssl
      }.to_yaml
    end
  end
end
