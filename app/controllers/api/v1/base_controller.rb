module Api
  module V1
    class BaseController < ApplicationController
      respond_to :json
      before_filter :default_json

      protected

      def require_user!
        if (!current_user)
          render json: {}, status: 401
        end
      end

      def require_admin!
        if !current_user or !(current_user.admin?)
          render json: {}, status: 401
        end
      end

      def require_owner!(user)
        if (!current_user.admin? and current_user != user)
          render json: {}, status: 401
        end
      end

      def default_json
        request.format = :json if params[:format].nil?
      end
    end
  end
end