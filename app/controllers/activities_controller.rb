require 'bcrypt'
class ActivitiesController < ApplicationController


  def index
    @activities = Activity.all
    render json:Activity.all
  end

  def show
   render json:Activity.last
  end

  def edit
  end

  def create
    @activity = Activity.new(activity_params)
    p params
      if @activity.save
        p @activity
       render json: @activity, status: 201
       # format.json {render json: => {"description"=> "Hello", "project_id"=> 4, "source"=> "what's up"}.to_json}
        # format.html { redirect_to @player, notice: 'Activity was successfully created.' }
        # format.json { render action: 'show', status: :created, location: activity_path(@activity) }
      else
        # format.html { render action: 'new' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
  end

  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to @player, notice: 'Activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to ActivitiesController_url }
      format.json { head :no_content }
    end
  end

private

  def activity_params
    params.require(:activity).permit(:description, :project_id, :source)
  end


end