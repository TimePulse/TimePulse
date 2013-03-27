require 'spec_helper'

describe InvoiceReport do

  describe "users" do
    let :user_1 do Factory(:user) end
    let :user_2 do Factory(:user) end
    let :user_3 do Factory(:user) end

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

    subject { InvoiceReport.new(invoice) }

    its(:users) { should include(user_1, user_2) }
    its(:users) { should_not include(user_3) }

  end

end
