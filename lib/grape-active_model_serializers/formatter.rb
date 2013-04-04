require 'active_record'

module Grape
  module Formatter
    module ActiveModelSerializers
      class << self

        attr_reader :env
        attr_reader :endpoint

        def call(object, env)
          @object = object
          @env = env
          @endpoint = env['api.endpoint']

          if object.is_a? ActiveRecord::Base and active_model_serializer?
            options = endpoint.options[:route_options][:serializer_options] || {}
            active_model_serializer.new(object).as_json options
          else
            Grape::Formatter::Json.call object, env
          end
        end

        private
        def active_model_serializer
          _active_model_serializer
        end

        def active_model_serializer?
          !!active_model_serializer
        end

        def _active_model_serializer
          route_options = endpoint.options[:route_options]

          # Infer serializer name if its not set
          route_options[:serializer] = @object.class.name unless route_options.has_key? :serializer

          serializer = route_options[:serializer]

          if serializer.instance_of? String or serializer.instance_of? Symbol
            name = "#{serializer.to_s.camelize}Serializer"
            serializer = Kernel.const_get(name)
          end
          serializer
        end
      end
    end
  end
end