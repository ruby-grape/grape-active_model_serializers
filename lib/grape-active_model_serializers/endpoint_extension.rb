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
      settings[:namespace] ? settings[:namespace].options : {}
    end

    def route_options
      options[:route_options]
    end

    def default_serializer_options; end
    def serialization_scope; end
    def _serialization_scope; end
    def url_options; end
  end

  Endpoint.send(:include, EndpointExtension)
end
