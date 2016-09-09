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
      if respond_to?(:inheritable_setting)
        inheritable_setting.namespace
      else
        settings[:namespace] ? settings[:namespace].options : {}
      end
    end

    def route_options
      if respond_to?(:inheritable_setting)
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
          return unless _serialization_scope
          return unless respond_to?(_serialization_scope, true)
          send(_serialization_scope)
        end
      end
    end

    def render(resources, extra_options = {})
      options = extra_options.symbolize_keys
      env['ams_meta'] = options.slice(
        :meta, :meta_key
      )
      env['ams_adapter'] = options.slice(
        :adapter, :serializer, :each_serializer
      )
      env['ams_extra'] = options[:extra]
      resources
    end

    def default_serializer_options
    end

    def url_options
    end
  end

  Endpoint.send(:include, EndpointExtension)
end
