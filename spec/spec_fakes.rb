
class User
  include ActiveModel::SerializerSupport
  attr_accessor :first_name, :last_name, :password, :email

  def initialize(params={})
    params.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
end

class UserSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name
end

class BlogPost
  include ActiveModel::SerializerSupport
  attr_accessor :title, :body

  def initialize(params={})
    params.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
end

class BlogPostSerializer < ActiveModel::Serializer
  attributes :title, :body
end
