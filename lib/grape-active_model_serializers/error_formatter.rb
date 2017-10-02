require 'multi_json'
module Grape
  module ErrorFormatter
    module ActiveModelSerializers
      extend Base

      class << self
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable LineLength
        def call(message, backtrace, options = {}, env = nil, original_exception = nil)
          # rubocop:enable Metrics/CyclomaticComplexity
          # rubocop:enable LineLength
          result = wrap_message(present(message, env))

          rescue_options = options[:rescue_options] || {}
          if rescue_options[:backtrace] && backtrace && !backtrace.empty?
            result = result.merge(backtrace: backtrace)
          end
          if rescue_options[:original_exception] && original_exception
            result = result
                     .merge(original_exception: original_exception.inspect)
          end

          MultiJson.dump(result)
        end

        private

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
