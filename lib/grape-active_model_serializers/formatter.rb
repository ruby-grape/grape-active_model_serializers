require 'active_record'

# Make the Grape::Endpoint quiack like a controller
module Grape
  class Endpoint
    def default_serializer_options; end
    def serialization_scope; end
    def _serialization_scope; end
    def url_options; end
  end
end

module Grape
  module Formatter
    module ActiveModelSerializers
      class << self
        attr_accessor :infer_serializers
        attr_reader :endpoint

        ActiveModelSerializers.infer_serializers = true

        def call(resource, env)
          @endpoint = env["api.endpoint"]

          namespace         = endpoint.settings[:namespace]
          namespace_options = namespace ? namespace.options : {}
          route_options     = endpoint.options[:route_options]
          options           = namespace_options.merge(route_options)

          serializer = ::ActiveModel::Serializer.build_json(endpoint, resource, options)

          if serializer
            serializer.to_json
          else
            Grape::Formatter::Json.call resource, env
          end
        end
      end
    end
  end
end
