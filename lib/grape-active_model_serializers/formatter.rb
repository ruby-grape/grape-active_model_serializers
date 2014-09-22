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

          if serializer = options.fetch(:serializer, ActiveModel::Serializer.serializer_for(resource))
            options[:scope] = endpoint unless options.has_key?(:scope)
            # ensure we have an root to fallback on
            options[:resource_name] = default_root(endpoint) if resource.respond_to?(:to_ary)
            serializer.new(resource, options.merge(other_options))
          end
        end

        def other_options
          options = {}
          if @meta_content_items
            if @meta_key
             key_option = @meta_key[:meta_key]
              @meta_key.delete(:meta_key)
              options[:meta_key] = key_option if key_option
            end
            meta_option = @meta_content_items[:meta]
            @meta_content_items.delete(:meta)
            options[key_option || :meta] = meta_option if meta_option
          end
          options
        end

        def meta
          @meta_content_items || {}
        end

        def meta=(meta_content)
          @meta_content_items = { meta: meta_content } if meta_content
        end

        def meta_key
          @meta_key || {}
        end

        def meta_key=(key)
          @meta_key = { meta_key: key } if key
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
