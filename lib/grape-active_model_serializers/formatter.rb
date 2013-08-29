module Grape
  module Formatter
    module ActiveModelSerializers
      class << self
        def call(resource, env)
          serializer = fetch_serializer(resource, env)

          if serializer
            serializer.to_json
          else
            Grape::Formatter::Json.call resource, env
          end
        end

        def fetch_serializer(resource, env)
          endpoint = env['api.endpoint']
          options = build_options_from_endpoint(endpoint)

          if resource.respond_to?(:to_ary) && !resource.empty?
            # ensure we have an root to fallback on
            endpoint.controller_name = resource.first.class.name.underscore.pluralize
          end
          ::ActiveModel::Serializer.build_json(endpoint, resource, options)
        end

        def build_options_from_endpoint(endpoint)
          endpoint.namespace_options.merge(endpoint.route_options)
        end
      end
    end
  end
end
