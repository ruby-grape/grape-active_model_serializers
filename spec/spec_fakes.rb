require 'active_model'

class User < ActiveRecord::Base
  attr_accessor :first_name, :last_name, :password, :email
end

class UserSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name
end

class BlogPost < ActiveRecord::Base
  attr_accessor :title, :body
end

class BlogPostSerializer < ActiveModel::Serializer
  attributes :title, :body
end
