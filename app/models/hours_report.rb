
# An HoursReport contains a detail of the total hours worked for a project,
# including breakdown by date range and by subproject.
#
# It may be created for an entire project by passing the project to
# HoursReport.new(), and it can be filtered to show only the hours for
# a single user by passing the user as a parameter, i.e.
# HoursReport.new(@project, :user => @user)
class HoursReport

  def initialize(project, user = nil)
    @report = {}
    @project = project.reload
    @user = user

    if @user
      @base_scope = @user.work_units.completed
    else
      @base_scope = WorkUnit.completed
    end

    build_totals_row
    build_by_time
    #build_by_project
  end

  # Returns a row of results, with total, unbilled, billed, paid, and unbillable.
  # Available rows:
  #   :totals (default)
  def totals
    hours_row()
  end
  def hours_row(row = :totals)
    @report[row]
  end
  def by_time(t = :today)
    @report[:by_time]
  end
  def by_project
    @report[:by_project]
  end


  private
  def project_scope(project)
    @base_scope.for_project(project)
  end
  def exclusive_scope(project)
    @base_scope.for_project_exclusive(project)
  end

  def build_totals_row
    @report[:totals] = build_row(project_scope(@project))
  end
  def build_by_time
    @report[:by_time] = {}
    @report[:by_time][:today] = build_row(project_scope(@project).today)
    @report[:by_time][:last_7] = build_row(project_scope(@project).in_last(7))
    @report[:by_time][:last_30] = build_row(project_scope(@project).in_last(30))
  end
  def build_by_project
    @report[:by_project] = {}
    @project.self_and_descendants.each do |proj|
      @report[:by_project][proj] = build_row(exclusive_scope(proj))
    end
  end


  def build_row(scope)
    # debugger
    {
      :total      => scope.send(:sum, :hours),
      :unbilled   => scope.unbilled.send(:sum, :hours),
      :unbillable => scope.unbillable.send(:sum, :hours)
    }
  end
end
