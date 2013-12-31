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
        p params
        @project = Project.new(params["projects"][0])

        if @project.save
          render :show, status: :created, location: api_v1_project_path(@project)
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def update
        @project = Project.find(params[:id])

        if @project.update_attributes(params[:project])
          render json: :no_content
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @project = Project.find(params[:id])
        @project.destroy

        render json: :no_content
      end

    end
  end
end
