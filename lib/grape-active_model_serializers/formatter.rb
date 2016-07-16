module Grape
  module Formatter
    module ActiveModelSerializers
      class << self
        def call(resource, env)
          options = build_options(resource, env)
          serializer = fetch_serializer(resource, options)

          if serializer
            ::ActiveModelSerializers::Adapter.create(
              serializer, options
            ).to_json
          else
            Grape::Formatter::Json.call resource, env
          end
        end

        def build_options(resource, env)
          endpoint = env['api.endpoint']
          options = build_options_from_endpoint(endpoint)

          options[:scope] = endpoint unless options.key?(:scope)

          # ensure we have a root to fallback on
          if resource.respond_to?(:to_ary) && !options.key?(:root)
            options[:root] = default_root(endpoint)
          end

          options.merge(meta_options(env))
        end

        def fetch_serializer(resource, options)
          # use serializer specified by options
          serializer = options[:serializer]

          begin
            # fetch serializer leverage AMS lookup
            serializer = ActiveModel::Serializer.serializer_for(resource)
            # if grape version exists, attempt to apply version namespacing
            serializer = namespace_serializer(serializer, options[:version])
          rescue LoadError
            # attempt to fetch serializer through namespace inference
            serializer = namespace_inferred_serializer(options)
          end if serializer.nil?

          return nil unless serializer

          options.merge!(collection_serializer_options(serializer, options))
          serializer.new(resource, options)
        end

        def namespace_serializer(serializer, namespace)
          "#{namespace.try(:classify)}::#{serializer}".constantize
        rescue NameError
          serializer
        end

        def collection_serializer_options(serializer, options)
          return {} if options.keys.include?(:serializer)
          if serializer == ActiveModel::Serializer::CollectionSerializer
            inferred_serializer = namespace_inferred_serializer(options)
            inferred_serializer ? { serializer: inferred_serializer } : {}
          else
            {}
          end
        end

        def namespace_inferred_serializer(options)
          klass = options[:for]
          return nil if klass.nil?
          "#{klass.to_s.classify}Serializer".constantize
        rescue NameError
          nil
        end

        def meta_options(env)
          options = {}
          ams_meta = env['ams_meta'] || {}
          meta = ams_meta.delete(:meta)
          meta_key = ams_meta.delete(:meta_key)
          options[:meta_key] = meta_key if meta && meta_key
          options[:meta] = meta if meta
          options
        end

        def build_options_from_endpoint(endpoint)
          [
            endpoint.default_serializer_options || {},
            endpoint.namespace_options,
            endpoint.route_options,
            endpoint.options,
            endpoint.options.fetch(:route_options)
          ].reduce(:merge)
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
