class BlogPost
  include ActiveModel::SerializerSupport
  attr_accessor :title, :body

  def initialize(params = {})
    params.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
end
