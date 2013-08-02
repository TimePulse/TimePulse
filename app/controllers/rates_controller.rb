class RatesController < ApplicationController
  before_filter :require_admin!

  # PUT /rates/1
  def update
    rate = Rate.find(params[:id])

    submitted_users = params[:users] ? User.find(params[:users]) : []

    deleted_users = rate.users - submitted_users
    added_users = submitted_users - rate.users

    rate.users.delete deleted_users
    rate.users << added_users

    rate.save

    project = Project.find(rate.project)
    redirect_to project, :action => :edit
  end
end
