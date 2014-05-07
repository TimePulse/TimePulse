require 'hhmm_to_decimal'

class WorkUnitsController < WorkUnitBaseController
  include HhmmToDecimal
  include UsersHelper

  before_filter :convert_hours_from_hhmm, :only => [ :update, :create ]

  before_filter :find_work_unit_and_authenticate, :only => [ :show, :edit, :update, :destroy ]

  # GET /work_units/1
  def show
  end

  # GET /work_units/new
  def new
    @work_unit = WorkUnit.new
  end

  # GET /work_units/1/edit
  def edit
    store_location
  end

  # POST /work_units
  def create
    parse_date_params
    if request.format.to_s == 'text/html' || request.format.to_s == 'text/javascript'
      @work_unit = WorkUnit.new(params[:work_unit])
    elsif request.format.to_s == 'application/json'
      pp request
      mapper = WorkUnitMapper.new(request.body.read)
      @work_unit = mapper.save
    end
    add_project

    @work_unit.user = current_user
    compute_some_fields

    @work_unit.project ||= current_user.current_project


    respond_to do |format|
      if @work_unit.save
        flash[:notice] = 'WorkUnit was successfully created.'
        format.html { redirect_to(@work_unit) }
        format.js {
          @work_unit = WorkUnit.new
          @work_units = current_user.completed_work_units_for(current_user.current_project).order("stop_time DESC").paginate(:per_page => 10, :page => nil)
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

    @work_unit.attributes = params[:work_unit]
    add_project

    compute_some_fields
    if @work_unit.save
      flash[:notice] = 'WorkUnit was successfully updated.'
      expire_fragment("work_unit_narrow_#{@work_unit.id}")
      expire_fragment("work_unit_one_line_#{@work_unit.id}")
      redirect_back
    else
      render :action => "edit"
    end
  end

  # DELETE /work_units/1
  def destroy
    @work_unit.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  private

  def add_project
    if params[:work_unit].has_key?(:project_id)
      @work_unit.project_id = params[:work_unit].delete(:project_id)
    end
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

  def redirect_back
    redirect_to(session[:return_to])
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.env["HTTP_REFERER"]
  end

end
