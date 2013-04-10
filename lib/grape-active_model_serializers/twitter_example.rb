module Twitter
  class API < Grape::API

    version 'v1', :using => :header, :vendor => 'twitter'
    format :json

    helpers do
      def current_user
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :statuses do

      desc "Return a public timeline."
      get :public_timeline do
        Status.limit(20)
      end

      desc "Return a personal timeline."
      get :home_timeline do
        authenticate!
        current_user.statuses.limit(20)
      end

      desc "Return a status."
      params do
        requires :id, :type => Integer, :desc => "Status id."
      end
      get ':id' do
        Status.find(params[:id])
      end

      desc "Create a status."
      params do
        requires :status, :type => String, :desc => "Your status."
      end
      post do
        authenticate!
        Status.create!({
          :user => current_user,
          :text => params[:status]
        })
      end

      desc "Update a status."
      params do
        requires :id, :type => String, :desc => "Status ID."
        requires :status, :type => String, :desc => "Your status."
      end
      put ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).update({
          :user => current_user,
          :text => params[:status]
        })
      end

      desc "Delete a status."
      params do
        requires :id, :type => String, :desc => "Status ID."
      end
      delete ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).destroy
      end

    end
  end
end