require 'active_record'
require 'pry'

module Grape
  module Formatter
    module ActiveModelSerializers
      class << self
        attr_accessor :infer_serializers
        attr_reader :env
        attr_reader :endpoint

        ActiveModelSerializers.infer_serializers = true

        def call(resource, env)
          # @object = object
          options = env['api.endpoint'].options[:route_options]

          serializer = serializer(endpoint, resource, options)

          if serializer
            serializer.to_json
          else
            Grape::Formatter::Json.call resource, env
          end
        end

        #   options = endpoint.options[:route_options][:serializer_options] || {}
        #   serializer.new(object, options).to_json
        # end

        private

      def serializer(endpoint, resource, options)
        # default_options = controller.send(:default_serializer_options) || {}
        options = {} #default_options.merge(options || {})

        serializer = options.delete(:serializer) ||
          (resource.respond_to?(:active_model_serializer) &&
           resource.active_model_serializer)

        return serializer unless serializer

        if resource.respond_to?(:to_ary)
          unless serializer <= ActiveModel::ArraySerializer
            raise ArgumentError.new("#{serializer.name} is not an ArraySerializer. " +
                                    "You may want to use the :each_serializer option instead.")
          end

          if options[:root] != false && serializer.root != false
            # the serializer for an Array is ActiveModel::ArraySerializer
            options[:root] ||= serializer.root || resource.first.class.name.downcase.pluralize
          end
        end

        # options[:scope] = controller.serialization_scope unless options.has_key?(:scope)
        # options[:scope_name] = controller._serialization_scope
        # options[:url_options] = controller.url_options

        serializer.new(resource, options)
      end
    end
  end
end