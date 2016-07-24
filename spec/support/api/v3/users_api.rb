module V3
  class UsersApi < Grape::API
    resource :users do
      desc 'all users'
      get do
        [User.new]
      end

      desc 'specified user'
      get '/:id' do
        User.new
      end
    end
  end
end
