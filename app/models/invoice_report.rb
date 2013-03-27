

class InvoiceReport
  attr_accessor :invoice, :work_units, :report

  def initialize(invoice)
    self.invoice = invoice
    self.work_units = invoice.work_units
  end

  def users(scope = self.work_units)
    scope.all.map{|wu| wu.user}.uniq
  end

  def days
    work_units.all.map{ |wu| wu.stop_time.to_date }.uniq.sort
  end

  def build_report
    days.map do |day|
      [ day, DateReport.new(work_units.where("date(stop_time) = ?")) ]
    end
  end


  class DateReport
    attr_accessor :report

    def initialize(date_scoped_units)
      @units = date_scoped_units
      @report = []
      @units.map{|wu| wu.user}.uniq.each do |user|
        @report << [ user ]
          #units_by_user.map{|wu| wu.hours }.sum,
          #units_by_user.reduce(""){|notes, wu| notes << (wu.notes + "\n")

      end
    end

    def units_by_user(user)

    end

  end

end
