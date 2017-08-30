module Grape
  module ErrorFormatter
    module ActiveModelSerializers
      extend Base

      class << self
        def call(message, backtrace, options = {}, env = nil)
          result = wrap_message(present(message, env))

          if (options[:rescue_options] || {})[:backtrace] && backtrace && !backtrace.empty?
            result = result.merge(backtrace: backtrace)
          end

          MultiJson.dump(result)

        end

        private

        def wrap_message(message)
          if message.respond_to?(:errors) && message.errors.is_a?(ActiveModel::Errors)
            ::ActiveModelSerializers::SerializableResource.new(message, {serializer: ActiveModel::Serializer::ErrorSerializer}).as_json
          elsif message.is_a?(Exceptions::ValidationErrors) || message.is_a?(Hash)
            message
          else
            { error: message }
          end
        end
      end
    end
  end
end
