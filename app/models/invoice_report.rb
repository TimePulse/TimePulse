

class InvoiceReport
  attr_accessor :invoice, :work_units, :report

  def initialize(invoice)
    self.invoice = invoice
    self.work_units = invoice.work_units
    self.report = build_report
  end

  def users(scope = self.work_units)
    scope.all.map{|wu| wu.user}.uniq
  end

  def days
    work_units.all.map{ |wu| wu.start_time.to_date }.uniq.sort
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
    attr_accessor :report

    def initialize(date_scoped_units)
      @units = date_scoped_units
      @report = []
      @units.map{|wu| wu.user}.uniq.each do |user|
        @report << [ user.name,
          units_by_user(user).map{|wu| wu.hours }.sum.to_s,
          units_by_user(user).map(&:notes).select(&:present?).join("\n")
        ]
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
        puts "\t" + user_row.last.gsub(/\n/, "\n\t")
        puts
      end
    end

  end

end
