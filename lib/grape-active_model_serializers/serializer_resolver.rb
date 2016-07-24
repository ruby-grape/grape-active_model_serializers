module Grape
  module ActiveModelSerializers
    class SerializerResolver
      def initialize(resource, options)
        self.resource = resource
        self.options = options
      end

      def serializer
        @serializer ||= (
          serializer_class.new(resource, options) if serializer_class
        )
      end

      private

      attr_accessor :resource, :options

      def serializer_class
        serializer_class = resource_defined_class
        serializer_class ||= collection_class
        serializer_class ||= options[:serializer]
        serializer_class ||= namespace_inferred_class
        serializer_class ||= version_inferred_class
        serializer_class ||= resource_serializer_class
        serializer_class
      end

      def resource_defined_class
        resource.serializer_class if resource.respond_to?(:serializer_class)
      end

      def collection_class
        return nil unless resource.respond_to?(:to_ary)
        ActiveModel::Serializer.config.collection_serializer
      end

      def namespace_inferred_class
        return nil unless options[:for]
        namespace = options[:for].to_s.deconstantize
        "#{namespace}::#{resource_serializer_klass}".safe_constantize
      end

      def version_inferred_class
        "#{version}::#{resource_serializer_klass}".safe_constantize
      end

      def version
        options[:version].try(:classify)
      end

      def resource_serializer_klass
        @resource_serializer_klass ||= [
          resource_namespace,
          "#{resource_klass}Serializer"
        ].compact.join('::')
      end

      def resource_klass
        resource.class.name.demodulize
      end

      def resource_namespace
        klass = resource.class.name.deconstantize
        klass.empty? ? nil : klass
      end

      def resource_serializer_class
        ActiveModel::Serializer.serializer_for(resource)
      end
    end
  end
end
