require 'hhmm_to_decimal'

class WorkUnitsController < WorkUnitBaseController
  before_filter :require_user!

  include HhmmToDecimal

  before_filter :convert_hours_from_hhmm, :only => [ :update, :create ]

  before_filter :find_work_unit_and_authenticate, :only => [ :show, :edit, :update, :destroy ]

  # GET /work_units/1
  def show
    @work_unit = WorkUnit.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @work_unit }
    end
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
      @work_unit = WorkUnit.new(work_unit_params)
      if annotation_params && annotation_params[:description].present?
        @annotation = Activity.new(annotation_params)
        @annotation.work_unit = @work_unit
      end

    elsif request.format.to_s == 'application/json'
      mapper = WorkUnitMapper.new(request.body.read)
      @work_unit = mapper.save
    end

    @work_unit.user = current_user
    compute_some_fields

    @annotation.time = @work_unit.stop_time if @annotation

    @work_unit.project ||= current_user.current_project


    respond_to do |format|
      if @work_unit.save
        @annotation.save if @annotation
        flash[:notice] = 'WorkUnit was successfully created.'
        format.html { redirect_to(@work_unit) }
        format.js {
          @work_unit = WorkUnit.new
          @work_units = current_user.completed_work_units_for(current_user.current_project).order(stop_time: :desc).paginate(:per_page => 10, :page => nil)
        }
        format.json { render json: @work_unit }
      else
        format.html { render :action => "new" }
        format.js
      end
    end
  end

  # PUT /work_units/1
  def update
    parse_date_params

    @work_unit.update(work_unit_params)

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

  def work_unit_params
    params.
    require(:work_unit).
    permit(:start_time,
      :stop_time,
      :hours,
      :billable,
      :project_id)
  end

  def annotation_params
    if params[:work_unit][:annotation]
      params.require(:work_unit).require(:annotation).permit(:description, :action, :source, :user_id, :project_id)
    end
  end

end
