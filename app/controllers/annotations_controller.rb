class AnnotationsController < ApplicationController
  #look at clock_time_controller
  #needs to do a js ajax request and create an activity that attaches to a work unit (mapper?)
  # POST /annotation
  def create
    parse_date_params

    if request.format.to_s == 'text/html' || request.format.to_s == 'text/javascript'
      @annotation = Activity.new(activity_params)
    elsif request.format.to_s == 'application/json'
      mapper = AnnotationMapper.new(request.body.read)
      @annotation = mapper.save
    end

    @annotation.user = current_user
    @annotation.work_unit = current_user.current_work_unit
    compute_some_fields

    @annotation.project ||= current_user.current_project


    respond_to do |format|
      if @annotation.save
        flash[:notice] = 'Annotation was successfully created.'
      # is this where I should render the recent annotations? or in application.js.erb??
      #   format.html { redirect_to(@annotation) }
      #   format.js {
      #     @annotation = Annotation.new
      #     @work_units = current_user.completed_work_units_for(current_user.current_project).order(stop_time: :desc).paginate(:per_page => 10, :page => nil)
      #   }
      #   format.json { render json: @work_unit }
      # else
      #   format.html { render :action => "new" }
      #   format.js
      end
    end
  end