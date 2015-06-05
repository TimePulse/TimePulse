class BillReport
  include ProjectsHelper

  def initialize(bill)
    @bill = bill
  end

  Project = Struct.new(:name, :hours)
  class WorkUnit < Struct.new(:id, :hours, :project_name, :notes, :start_time)
    def self.model_name
      self
    end

    def self.param_key
      "work_unit"
    end

    def to_key
      [id.to_s]
    end


    undef_method :to_a
  end

  attr_reader :bill

  def clockable_projects
    @clockable_projects ||=
      begin
        bill.work_units.includes(:project).map(&:project).find_all do |project|
          project.clockable?
        end.uniq
      end
  end

  def total_hours
    @total_hours ||= projects_and_hours.inject(0) do |total, proj|
      total + proj.hours
    end
  end

  def projects_and_hours
    @projects_and_hours ||=
      begin
        clockable_projects.map do |proj|
          Project.new(
            project_name_with_client(proj),
            ProjectWorkQuery.new(bill.work_units.billable).find_for_project(proj).sum(:hours)
          )
        end
      end
  end

  def work_units_and_hours
    bill.work_units.includes(:project).billable.order(:start_time => :asc).find_all do |wu|
      wu.project.clockable?
    end.map do |wu|
      WorkUnit.new(
        wu.id,
        wu.hours,
        project_name_with_client(wu.project),
        wu.notes,
        wu.start_time.try(:to_s, :short_date_and_time)
      )
    end.tap{|list| Rails.logger.fatal(list.inspect)}
  end

end
