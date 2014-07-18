class InvoiceReport
  attr_accessor :invoice, :work_units, :report

  def initialize(invoice)
    self.invoice = invoice
    self.work_units = invoice.work_units
    self.report = build_report
  end

  def users(scope = self.work_units)
    scope.to_a.map{|wu| wu.user}.uniq
  end

  def days
    work_units.to_a.map{ |wu| wu.start_time.to_date }.uniq.sort
  end

  def build_report
    days.map do |day|
      [ day, DateReport.new(work_units.select{|wu| wu.start_time.to_date == day }) ]
    end
  end

  def print_report
    report.each do |date_row|
      puts date_row.first.to_s
      date_row.last.print
    end
  end


  class DateReport
    include ActionView::Helpers::TextHelper

    attr_accessor :report

    def initialize(date_scoped_units)
      @units = date_scoped_units
      @report = []
      @units.map{|wu| wu.user}.uniq.each do |user|
        @report << [ user.name,
          units_by_user(user).map{|wu| wu.hours }.sum.to_s,
          units_by_user(user).map(&:notes).select(&:present?),
          units_by_user(user).map{|wu| work_unit_commits(wu)}.flatten.uniq,
          units_by_user(user).map{|wu| work_unit_pivotal_updates(wu)}.flatten.uniq
        ]
      end
    end

    def work_unit_commits(work_unit)
      start_time = work_unit.start_time.advance(:minutes => -15)
      stop_time = work_unit.stop_time.advance(:minutes => 15)
      commits = work_unit.user.git_commits_for(work_unit.project).where("time >= ? and time <= ?", start_time, stop_time)
      commits.to_a.map do |commit|
        truncate(commit.reference_1, :length => 10) + " \"#{commit.description}\""
      end
    end

    def work_unit_pivotal_updates(work_unit)
      start_time = work_unit.start_time.advance(:minutes => -15)
      stop_time = work_unit.stop_time.advance(:minutes => 15)
      pivotal_updates = work_unit.user.pivotal_updates_for(work_unit.project).story_changes.where("time >= ? and time <= ?", start_time, stop_time)
      pivotal_updates.to_a.map do |pivotal|
        truncate(pivotal.reference_1, :length => 10) + " #{pivotal.description}"
      end
    end

    def units_by_user(user)
      @units.select{ |wu| wu.user == user }
    end

    def to_s
      report.to_s
    end
    def inspect
      report.inspect
    end

    def print
      report.each do |user_row|
        puts "\t#{user_row.first}: #{user_row[1]}"

        puts
      end
    end

  end

end
