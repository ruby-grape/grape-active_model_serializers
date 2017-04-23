module Grape
  module ActiveModelSerializers
    class SerializerResolver
      def initialize(resource, options)
        self.resource = resource
        self.options = options
      end

      def serializer
        serializer_class.new(resource, serializer_options) if serializer_class
      end

      private

      attr_accessor :resource, :options

      def serializer_class
        return @serializer_class if defined?(@serializer_class)
        @serializer_class = resource_defined_class
        @serializer_class ||= collection_class
        @serializer_class ||= options[:serializer]
        @serializer_class ||= namespace_inferred_class
        @serializer_class ||= version_inferred_class
        @serializer_class ||= resource_serializer_class
      end

      def serializer_options
        if collection_serializer? && !options.key?(:serializer)
          options.merge(each_serializer_option)
        else
          options
        end
      end

      def collection_serializer?
        serializer_class == ActiveModel::Serializer.config.collection_serializer
      end

      def each_serializer_option
        serializer_class = options[:each_serializer]
        serializer_class ||= namespace_inferred_class
        serializer_class ||= version_inferred_class
        serializer_class ? { serializer: serializer_class } : {}
      end

      def resource_defined_class
        resource.serializer_class if resource.respond_to?(:serializer_class)
      end

      def collection_class
        if resource.respond_to?(:to_ary) || resource.respond_to?(:all)
          ActiveModel::Serializer.config.collection_serializer
        end
      end

      def namespace_inferred_class
        return nil unless options.key?(:for)
        namespace = options[:for].to_s.deconstantize
        "#{namespace}::#{resource_serializer_klass}".safe_constantize
      end

      def version_inferred_class
        return nil unless options.key?(:version)
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
        resource_class.name.demodulize
      end

      def resource_namespace
        klass = resource_class.name.deconstantize
        klass.empty? ? nil : klass
      end

      def resource_class
        if resource.respond_to?(:klass)
          resource.klass
        elsif resource.respond_to?(:to_ary) || resource.respond_to?(:all)
          resource.first.class
        else
          resource.class
        end
      end

      def resource_serializer_class
        ActiveModel::Serializer.serializer_for(resource)
      end
    end
  end
end
