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
            endpoint.controller_name = default_root(endpoint)
          end
          ::ActiveModel::Serializer.build_json(endpoint, resource, options)
        end

        def build_options_from_endpoint(endpoint)
          endpoint.namespace_options.merge(endpoint.route_options)
        end

        # array root is the innermost namespace name ('space') if there is one,
        # otherwise the route name (e.g. get 'name')
        def default_root(endpoint)
          innermost_scope = endpoint.settings.peek

          if innermost_scope[:namespace]
            innermost_scope[:namespace].space
          else
            endpoint.options[:path][0].to_s.split('/')[-1]
          end
        end
      end
    end
  end
end
