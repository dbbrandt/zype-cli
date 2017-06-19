require 'net/https'
require 'httparty'
require 'pry'

module Zype
  class Client

    class NoApiKey < StandardError; end
    class NoUploadKey < StandardError; end
    class NotFound < StandardError; end
    class ServerError < StandardError; end
    class ImATeapot < StandardError; end
    class Unauthorized < StandardError; end
    class UnprocessableEntity < StandardError; end

    # for error types not explicity mapped
    class GenericError < StandardError; end

    ERROR_TYPES = {
      '401' => Unauthorized,
      '404' => NotFound,
      '418' => ImATeapot,
      '422' => UnprocessableEntity,
      '500' => ServerError
    }.freeze

    class << self
      alias_method :old_new, :new

      def new(options={})
        setup_requirements

        old_new
      end

      def setup_requirements
        @required ||= false
        unless @required
          for model in models
            require [@model_path, model].join('/')
          end
          for collection in collections
            require [@model_path, collection].join('/')
            constant = collection.to_s.split('_').map {|characters| characters[0...1].upcase << characters[1..-1]}.join('')
            Zype::Client.class_eval <<-EOS, __FILE__, __LINE__
              def #{collection}(attributes = {})
                Zype::#{constant}.new({:service => self}.merge(attributes))
              end
            EOS
          end
          @required = true
        end
      end

      def collection(new_collection)
        collections << new_collection
      end

      def collections
        @collections ||= []
      end

      def model_path(new_path)
        @model_path = new_path
      end

      def model(new_model)
        models << new_model
      end

      def models
        @models ||= []
      end

      def request_path(new_path)
        @request_path = new_path
      end

      def request(new_request)
        requests << new_request
      end

      def requests
        @requests ||= []
      end
    end

    model_path 'zype/models'

    model :account
    model :category
    model :consumer
    model :device
    model :device_category
    model :plan
    model :playlist
    model :revenue_model
    model :subscription
    model :upload
    model :video
    model :video_import
    model :video_source
    model :zobject_type
    model :zobject

    collection :categories
    collection :consumers
    collection :devices
    collection :device_categories
    collection :plans
    collection :playlists
    collection :revenue_models
    collection :subscriptions
    collection :uploads
    collection :videos
    collection :video_imports
    collection :video_sources
    collection :zobject_types
    collection :zobjects

    include HTTParty

    def initialize
      @headers = { "Content-Type" => "application/json" }
      @headers["x-zype-key"] = Zype.configuration.api_key if Zype.configuration.api_key
      @params =  Zype.configuration.app_key ? { app_key: Zype.configuration.app_key } : { app_key: ENV["ZYPE_APP_KEY"] }
      self.class.base_uri set_base_uri
    end

    def account
      Zype::Account.new(get('/account')['response'])
    end

    def get(path,params={})
      raise NoApiKey unless set_keys(params)
      puts "The params for get are: #{params.inspect}"

      # iterate through and remove params that are nil
      params.delete_if { |k, v| v.nil? }

      self.class.get(path, { query: @params, headers: @headers })
    end

    def post(path,params={})
      raise NoApiKey unless set_keys(params)

      self.class.post(path, { query: @params, headers: @headers })
    end

    def put(path,params={})
      raise NoApiKey unless set_keys(params)

      self.class.put(path, { query: @params, headers: @headers })
    end

    def delete(path,params={})
      raise NoApiKey unless set_keys(params)

      self.class.delete(path, { query: @params, headers: @headers })
    end

    def success!(status, response)
      response
    end

    def error!(status,response)
      error_type = ERROR_TYPES[status] || GenericError
      raise error_type.new(response['message'])
    end

    def set_keys(params)
      @params[:app_key] = params[:app_key] if params.key?(:app_key)
      return @params.key?(:app_key) || @headers.key?("x-zype-key")
    end

    def set_base_uri
      if Zype.configuration.use_ssl
        start_url = 'https://'
      else
        start_url = 'http://'
      end

      start_url + Zype.configuration.host + ':' + Zype.configuration.port.to_s
    end
  end
end
