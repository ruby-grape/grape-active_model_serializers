module Grape
  module ActiveModelSerializers
    class SerializerResolver
      def initialize(resource, options)
        self.resource = resource
        self.options = options
      end

      def serializer
        @serializer ||= (
          serializer_klass.new(resource, options) if serializer_klass
        )
      end

      private

      attr_accessor :resource, :options

      def serializer_klass
        serializer_klass = options[:serializer]
        serializer_klass ||= namespaced_resource_serializer_klass
        serializer_klass
      end

      def namespaced_resource_serializer_klass
        "#{namespace}::#{resource_serializer_klass}".constantize
      rescue NameError
        resource_serializer_klass
      end

      def namespace
        options[:version].try(:classify)
      end

      def resource_serializer_klass
        @resource_serializer_klass ||= ActiveModel::Serializer.serializer_for(
          resource
        )
      end
    end
  end
end
