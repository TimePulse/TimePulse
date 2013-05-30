class PivotalController < ApplicationController
  def create
    payload = params.deep_symbolize_keys[:activity]
    @pivotal_activity = PivotalActivity.new(payload)
    @pivotal_activity.save

    respond_to do |format|
      format.html { render :nothing => true }
      format.json { head :ok }
    end
  end
end