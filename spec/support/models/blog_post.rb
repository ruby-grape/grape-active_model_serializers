class BlogPost
  include ActiveModel::Serialization

  attr_accessor :title, :body

  def self.model_name
    to_s
  end

  def initialize(params = {})
    params.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
end
