class RatesController < ApplicationController
  before_filter :require_admin!

  # PUT /rates/1
  def update
    rate = Rate.find(params[:id])

    rate.users << User.find(params[:add_user]) unless params[:add_user].blank?

    unless params[:delete_user].blank?
      params[:delete_user].map! { |s| s.to_i }.uniq
      users_to_delete = User.find params[:delete_user]
      rate.users.delete users_to_delete
    end

    rate.save

    project = Project.find(rate.project)
    redirect_to project, :action => :edit
  end
end
