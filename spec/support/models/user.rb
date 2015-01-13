class User
  include ActiveModel::SerializerSupport
  attr_accessor :first_name, :last_name, :password, :email

  def initialize(params = {})
    params.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
end
