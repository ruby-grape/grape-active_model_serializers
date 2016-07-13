class User
  include ActiveModel::Serialization

  attr_accessor :first_name, :last_name, :password, :email

  def self.model_name
    to_s
  end

  def initialize(params = {})
    params.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
end
