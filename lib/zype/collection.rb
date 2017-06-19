module Zype
  class Collection < Array
    attr_reader :service

    # Defines lazy loaded facades to array methods (ex: select, reject slice)
    Array.public_instance_methods(false).each do |method|
      class_eval <<-EOS, __FILE__, __LINE__
        def #{method}(*args)
          lazy_load unless @loaded
          super
        end
      EOS
    end

    # Defines lazy loaded facades for paging variables
    %w(current_page previous_page next_page per_page total_pages).each do |method|
      class_eval <<-EOS, __FILE__, __LINE__
        def #{method}
          lazy_load unless @loaded
          @#{method}
        end
      EOS
    end


    # Alias limit_value for kaminary compatability
    alias_method :limit_value, :per_page


    def self.model(new_model=nil)
      if new_model == nil
        @model
      else
        @model = new_model
      end
    end


    def model
      self.class.instance_variable_get('@model')
    end

    def initialize(attributes={})
      @service = attributes.delete(:service)
      @loaded = false
      merge_attributes!(attributes)
    end

    def clear
      @loaded = true
      super
    end

    def load(response={})
      clear

      if data = response["response"]  
        if data.is_a?(Hash)
          return model.new({:service => service}.merge(data))
        elsif data.is_a?(Array)
          for d in data
            self << model.new({:service => service}.merge(d))
          end

          load_pagination(response)
        end
      else
        raise(ArgumentError.new("Response data must be Hash or Array. Resopnse Message: #{response["message"]}"))
      end

      self
    end


    def load_pagination(response={})
      if pagination = response["pagination"]
        @current_page = pagination["current"]
        @prev_page    = pagination["previous"]
        @next_page    = pagination["next"]
        @total_pages  = pagination["pages"]
        @per_page     = pagination["per_page"]

      end
    end

    def merge_attributes!(attributes = {})
      attributes.each_pair do |att, value|
        self.send("#{att}=", value) if self.respond_to?("#{att}=")
      end
      self
    end



  private

    def lazy_load
      self.all
      @loaded = true
    end
  end
end
