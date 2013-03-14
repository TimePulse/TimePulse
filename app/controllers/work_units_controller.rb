require 'hhmm_to_decimal'

class WorkUnitsController < ApplicationController
  include HhmmToDecimal

  before_filter :convert_hours_from_hhmm, :only => [ :update, :create ]

  before_filter :find_work_unit_and_authenticate, :only => [ :show, :edit, :update, :destroy ]

  # GET /work_units
  def index
    @work_units = WorkUnit.find(:all)
  end

  # GET /work_units/1
  def show
  end

  # GET /work_units/new
  def new
    @work_unit = WorkUnit.new
  end

  # GET /work_units/1/edit
  def edit
  end

  def switch
    if current_user && current_user.current_work_unit
      current_user.current_work_unit.clock_out!
    end
    create
  end

  # POST /work_units
  def create
    parse_date_params
    @work_unit = WorkUnit.new(params[:work_unit])
    @work_unit.user = current_user
    compute_some_fields
    @work_unit.project ||= current_user.current_project

    respond_to do |format|
      if @work_unit.save
        flash[:notice] = 'WorkUnit was successfully created.'
        format.html { redirect_to(@work_unit) }
        format.js {
          @work_unit = WorkUnit.new
          @work_units = current_user.work_units_for(current_user.current_project).order("stop_time DESC").paginate(:per_page => 10, :page => nil)
        }
      else
        format.html { render :action => "new" }
        format.js
      end
    end
  end

  # PUT /work_units/1
  def update
    parse_date_params
    Rails.logger.debug{params.inspect}
    @work_unit.attributes = params[:work_unit]
    compute_some_fields
    if @work_unit.save
      flash[:notice] = 'WorkUnit was successfully updated.'
      expire_fragment("work_unit_narrow_#{@work_unit.id}")
      expire_fragment("work_unit_one_line_#{@work_unit.id}")
      redirect_to(@work_unit)
    else
      render :action => "edit"
    end
  end

  # DELETE /work_units/1
  def destroy
    @work_unit.destroy
    redirect_to :back
  end

  private
  def parse_date_params

    if wu_p = params[:work_unit]
      wu_p[:start_time] = Chronic.parse(wu_p[:start_time]) if wu_p[:start_time]
      wu_p[:stop_time] = Chronic.parse(wu_p[:stop_time]) if wu_p[:stop_time]
    end
  end

  def find_work_unit_and_authenticate
    @work_unit = WorkUnit.find(params[:id])
    raise ArgumentError, 'Invalid work_unit id provided' unless @work_unit
    authenticate_owner!(@work_unit.user)
  end

  # compute a few fields based on sensible defaults, if "calculate" param was passed
  def compute_some_fields
    if params["work_unit"]["calculate"]
      @work_unit.stop_time = Time.zone.now if @work_unit.stop_time.blank?

      if @work_unit.hours.blank?
        @work_unit.hours = WorkUnit.decimal_hours_between(@work_unit.start_time, @work_unit.stop_time)
      end
    end
  end


end
