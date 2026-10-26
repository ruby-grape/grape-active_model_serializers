module Grape
  module ErrorFormatter
    class ActiveModelSerializers < Base
      class << self
        def call(*args, **kwargs)
          return super if kwargs.key?(:error)

          call_with_positional_arguments(*args, **kwargs)
        end

        private

        def format_structured_message(message)
          if ::Grape.const_defined? :Json
            ::Grape::Json.dump(message)
          else
            ::MultiJson.dump(message)
          end
        end

        def call_with_positional_arguments(message, backtrace, options = {},
                                           env = nil, original_exception = nil)
          message = present(message, env) if respond_to?(:present)
          message = wrap_message(message)

          rescue_options = options[:rescue_options] || {}
          if rescue_options[:backtrace] && backtrace && !backtrace.empty?
            message = message.merge(backtrace: backtrace)
          end
          if rescue_options[:original_exception] && original_exception
            message = message
                      .merge(original_exception: original_exception.inspect)
          end
          format_structured_message(message)
        end

        def wrap_message(message)
          if active_model?(message)
            ::ActiveModelSerializers::SerializableResource.new(
              message,
              serializer: ActiveModel::Serializer::ErrorSerializer
            ).as_json
          elsif ok_to_pass_through?(message)
            message
          else
            { error: message }
          end
        end

        def active_model?(message)
          message.respond_to?(:errors) &&
            message.errors.is_a?(ActiveModel::Errors)
        end

        def ok_to_pass_through?(message)
          message.is_a?(Exceptions::ValidationErrors) ||
            message.is_a?(Hash)
        end
      end
    end
  end
end
