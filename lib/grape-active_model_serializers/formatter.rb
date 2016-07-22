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
            Grape::Formatter::Json.call(resource, env)
          end
        end

        def build_options(resource, env)
          Grape::ActiveModelSerializers::OptionsBuilder.new(
            resource, env
          ).options
        end

        def fetch_serializer(resource, options)
          Grape::ActiveModelSerializers::SerializerResolver.new(
            resource, options
          ).serializer
        end
      end
    end
  end
end
