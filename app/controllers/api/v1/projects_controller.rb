module Api
  module V1
    class ProjectsController < BaseController
      before_filter :require_user!, :only => [:index, :show]
      before_filter :require_admin!, :only => [:create, :update, :destroy]

      def index
        if params[:ids]
          @projects = Project.find(params[:ids])
        else
          @projects = Project.all
        end
        respond_with @projects
      end

      def show
        @project = Project.find(params[:id])
        respond_with @project
      end

      def create
        @project = Project.new(params[:project])

        if @project.save
          render json: @project, status: :created
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def update
      end

      def destroy
      end

    end
  end
end
