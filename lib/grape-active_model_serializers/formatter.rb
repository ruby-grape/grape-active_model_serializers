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

          serializer = options.fetch(:serializer, ActiveModel::Serializer.serializer_for(resource))
          return nil unless serializer

          options[:scope] = endpoint unless options.key?(:scope)
          # ensure we have an root to fallback on
          options[:resource_name] = default_root(endpoint) if resource.respond_to?(:to_ary)
          serializer.new(resource, options.merge(other_options(env)))
        end

        def other_options(env)
          options = {}
          ams_meta = env['ams_meta'] || {}
          meta =  ams_meta.delete(:meta)
          meta_key = ams_meta.delete(:meta_key)
          options[:meta_key] = meta_key if meta && meta_key
          options[meta_key || :meta] = meta if meta
          options
        end

        def build_options_from_endpoint(endpoint)
          [endpoint.default_serializer_options || {}, endpoint.namespace_options, endpoint.route_options, endpoint.options, endpoint.options.fetch(:route_options)].reduce(:merge)
        end

        # array root is the innermost namespace name ('space') if there is one,
        # otherwise the route name (e.g. get 'name')
        def default_root(endpoint)
          innermost_scope = if endpoint.respond_to?(:namespace_stackable)
                              endpoint.namespace_stackable(:namespace).last
                            else
                              endpoint.settings.peek[:namespace]
                            end

          if innermost_scope
            innermost_scope.space
          else
            endpoint.options[:path][0].to_s.split('/')[-1]
          end
        end
      end
    end
  end
end
