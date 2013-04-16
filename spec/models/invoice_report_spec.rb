require 'spec_helper'

describe InvoiceReport do

  let :user_1 do Factory(:user) end
  let :user_2 do Factory(:user) end
  let :user_3 do Factory(:user) end

  subject { InvoiceReport.new(invoice) }

  describe "users" do
    let :work_unit_1 do
      Factory(:work_unit, :hours => 1.0, :user => user_1)
    end
    let :work_unit_2 do
      Factory(:work_unit, :hours => 2.0, :user => user_2)
    end
    let :work_unit_3 do
      Factory(:work_unit, :hours => 3.0, :user => user_3)
    end

    let :invoice do
      Factory.create(:invoice, :work_units => [work_unit_1, work_unit_2])
    end


    its(:users) { should include(user_1, user_2) }
    its(:users) { should_not include(user_3) }

  end

  describe "days" do
    let :work_units do
      [].tap do |arr|
        5.times do |n|
          start = n.days.ago.beginning_of_day
          arr << Factory(:work_unit, :hours => 1.0,
                         :start_time => start,
                         :stop_time  => start + 1.hour)
        end
      end
    end

    let :invoice do
      Factory.create(:invoice, :work_units => work_units)
    end

    its(:days) { should have(5).days }
    its(:days) { should include(date_ago(4)) }
    its(:days) { should include(date_ago(0)) }
    its(:days) { should_not include(date_ago(5)) }

    def date_ago(days)
      days.days.ago.beginning_of_day.to_date
    end

  end

  describe InvoiceReport::DateReport do
    context "with one contributing user" do
      let :work_units do
        [ Factory(:work_unit, :user => user_1),
          Factory(:work_unit, :user => user_1)
        ]
      end

      subject { InvoiceReport::DateReport.new(work_units) }
      its(:report) { should have(1).rows }
    end
    context "with two contributing users" do
      let :work_units do
        [ Factory(:work_unit, :user => user_1),
          Factory(:work_unit, :user => user_2)
        ]
      end
      subject { InvoiceReport::DateReport.new(work_units) }
      its(:report) { should have(2).rows }
    end
  end

end
