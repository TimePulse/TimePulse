class GithubController < ApplicationController
  def create
    payload = JSON.parse(params[:payload], :symbolize_names => true)
    @github_update = GithubUpdate.new(payload)
    @github_update.save

    respond_to do |format|
      format.html { render :nothing => true }
      format.json { head :ok }
    end
  end
end