module Grape
  module ActiveModelSerializers
    class OptionsBuilder
      def initialize(resource, env)
        self.resource = resource
        self.env = env
      end

      def options
        @options ||= (
          options = endpoint_options
          options[:scope] = endpoint unless options.key?(:scope)
          options.merge!(default_root_options) unless options.key?(:root)
          options.merge!(meta_options)
          options.merge!(adapter_options)
          options
        )
      end

      private

      attr_accessor :resource, :env

      def endpoint_options
        [
          endpoint.default_serializer_options || {},
          endpoint.namespace_options,
          endpoint.route_options,
          endpoint.options,
          endpoint.options.fetch(:route_options)
        ].reduce(:merge)
      end

      def endpoint
        @endpoint ||= env['api.endpoint']
      end

      # array root is the innermost namespace name ('space') if there is one,
      # otherwise the route name (e.g. get 'name')
      def default_root_options
        return {} unless resource.respond_to?(:to_ary)

        if innermost_scope
          { root: innermost_scope.space }
        else
          { root: endpoint.options[:path].first.to_s.split('/').last }
        end
      end

      def innermost_scope
        if endpoint.respond_to?(:namespace_stackable)
          endpoint.namespace_stackable(:namespace).last
        else
          endpoint.settings.peek[:namespace]
        end
      end

      def meta_options
        options = {}
        ams_meta = env['ams_meta'] || {}
        meta = ams_meta[:meta]
        meta_key = ams_meta[:meta_key]
        options[:meta] = meta if meta
        options[:meta_key] = meta_key if meta && meta_key
        options
      end

      def adapter_options
        env['ams_adapter_options'] || {}
      end
    end
  end
end
