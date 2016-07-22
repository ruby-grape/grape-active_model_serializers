module V3
  class UserSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name, :email
  end
end
