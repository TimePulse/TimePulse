class CurrentProjectController < ApplicationController
  def create    
    current_user.update_attribute(:current_project_id, params[:id]) if params[:id]
    respond_to do |format|
      format.html { redirect_to :back }
      format.js 
    end
  end  
end
