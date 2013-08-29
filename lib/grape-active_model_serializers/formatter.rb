module Grape
  module Formatter
    module ActiveModelSerializers
      class << self
        def call(resource, env)
          endpoint = env['api.endpoint']
          options   = endpoint.namespace_options.merge(endpoint.route_options)

          if resource.respond_to?(:to_ary) && !resource.empty?
            # ensure we have an root to fallback on
            endpoint.controller_name = resource.first.class.name.underscore.pluralize
          end

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
