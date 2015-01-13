#
# Make the Grape::Endpoint quack like a ActionController
#
# This allows us to rely on the ActiveModel::Serializer#build_json method
# to lookup the approriate serializer.
#
module Grape
  module EndpointExtension
    attr_accessor :controller_name

    def namespace_options
      if self.respond_to?(:inheritable_setting)
        inheritable_setting.namespace
      else
        settings[:namespace] ? settings[:namespace].options : {}
      end
    end

    def route_options
      if self.respond_to?(:inheritable_setting)
        inheritable_setting.route
      else
        options[:route_options]
      end
    end

    def self.included(base)
      mattr_accessor :_serialization_scope
      self._serialization_scope = :current_user

      base.class_eval do
        def serialization_scope
          send(_serialization_scope) if _serialization_scope && respond_to?(_serialization_scope, true)
        end
      end
    end

    def render(resources, meta={})
      set_meta_and_meta_key(meta)
      resources
    end

    def default_serializer_options; end

    def url_options; end

    private

    def set_meta_and_meta_key(meta)
      Formatter::ActiveModelSerializers.meta = meta[:meta]
      Formatter::ActiveModelSerializers.meta_key = meta[:meta_key]
    end

  end
  Endpoint.send(:include, EndpointExtension)
end
