require 'spec_helper'

describe ProjectReport, type: :presenter do

  let :project_1 do FactoryGirl.create(:project, :with_rate) end
  let :project_2 do FactoryGirl.create(:project, :with_rate) end
  let :user_1 do FactoryGirl.create(:user) end
  let :user_2 do FactoryGirl.create(:user) end
  let :user_3 do FactoryGirl.create(:user) end
  let! :rates_user_1 do FactoryGirl.create(:rates_user, :rate => project_1.rates.first, :user => user_1) end
  let! :rates_user_2 do FactoryGirl.create(:rates_user, :rate => project_1.rates.first, :user => user_2) end
  let! :rates_user_3 do FactoryGirl.create(:rates_user, :rate => project_2.rates.first, :user => user_3) end
  let! :work_unit_1 do FactoryGirl.create(:work_unit, :project => project_1, :user => user_1, :hours => 1.5) end
  let! :work_unit_2 do FactoryGirl.create(:work_unit, :project => project_1, :user => user_1, :hours => 2.5) end

  let :decimal_project do FactoryGirl.create(:project) end
  let! :decimal_rate do FactoryGirl.create(:rate, :amount => 100.50, :project => decimal_project) end

  describe '#users' do
    subject { ProjectReport.new(project_1).users }

    it { should include(user_1) }
    it { should_not include(user_2, user_3) }
  end

  describe '#rates' do
    subject { ProjectReport.new(project_1).rates }

    it { should eq(project_1.rates) }
    it { should_not eq(project_2.rates) }
  end

  describe '#user_hours' do
    subject { ProjectReport.new(project_1).user_hours }

    it "should return sum of user's hours on project at key user_id" do
      total_hours = work_unit_1.hours + work_unit_2.hours
      expect(subject[user_1.id]).to eq(total_hours)
    end
    it "should retrun nil for unrelated user ids" do
      expect(subject[user_2.id]).to eq(nil)
    end
  end

  describe '#rate_hours' do
    subject { ProjectReport.new(project_1).rate_hours }

    it "should return sum of rate's hours on project at key rate_id" do
      total_hours = work_unit_1.hours + work_unit_2.hours
      expect(subject[project_1.rates.first.id]).to eq(total_hours)
    end
  end

  describe '#work_units' do
    let :unrelated_work_unit do
      FactoryGirl.create(:work_unit, :project => project_2)
    end

    subject { ProjectReport.new(project_1).work_units }

    it { should include(work_unit_1, work_unit_2) }
    it { should_not include(unrelated_work_unit) }
  end

  describe '#build_user_report' do

    describe 'rows' do
      subject { ProjectReport.new(project_1).build_user_report.keys }

      context 'with one contributing user' do
        its (:length) { should eq(1) }
        it { should include(user_1.id) }
        it { should_not include(user_3.id) }
      end

      context 'with two contributing users' do
        let! :work_unit_3 do
          FactoryGirl.create(:work_unit, :project => project_1, :user => user_2)
        end

        its(:length) { should eq(2) }
        it { should include(user_2.id, user_1.id) }
        it { should_not include(user_3.id) }
      end
    end

    describe 'item' do
      subject { ProjectReport.new(project_1).build_user_report[user_1.id] }

      describe 'keys' do
        it 'should have key :name' do
          expect(subject).to have_key(:name)
        end
        it 'should have key :hours' do
          expect(subject).to have_key(:hours)
        end
        it 'should have key :rate' do
          expect(subject).to have_key(:rate)
        end
        it 'should have key :cost' do
          expect(subject).to have_key(:cost)
        end
      end

      describe 'values' do
        let :total_hours do
          work_unit_1.hours + work_unit_2.hours
        end
        let :total_cost do
          user_1.rate_for(project_1).amount * total_hours
        end
        it 'should store users name with key :name' do
          expect(subject[:name]).to eq(user_1.name)
        end
        it 'should store users rate with key :rate' do
          project_rate = user_1.rate_for(project_1).amount
          expect(subject[:rate].to_f).to eq(project_rate)
        end
        it 'should calculate and store user total hours with key :hours' do
          expect(subject[:hours]).to eq(total_hours)
        end
        it 'should calculate and store users total cost (rate * hours) with key :cost' do
          expect(subject[:cost]).to eq(total_cost)
        end

        context "for project with no rates" do
          let :project_1 do FactoryGirl.create(:project) end

          it 'should store users name with key :name' do
            expect(subject[:name]).to eq(user_1.name)
          end
          it 'should store users rate as 0' do
            expect(subject[:rate].to_f).to eq(0.0)
          end
          it 'should calculate and store user total hours with key :hours' do
            expect(subject[:hours]).to eq(total_hours)
          end
          it 'should calculate and store users total cost as 0' do
            expect(subject[:cost]).to eq(0.0)
          end
        end
      end
    end
  end

  #TODO: flesh out specs below
  describe '#build_rate_report' do
    let :rate_1 do project_1.rates.first end
    let :rate_2 do project_2.rates.first end

    describe 'rows' do

      subject { ProjectReport.new(project_1).build_rate_report.keys }

      context 'with one rate types' do
        its (:length) { should eq(1) }
        it { should include(rate_1.id) }
        it { should_not include(rate_2.id) }
      end

      context 'with two rate types' do
        let! :rate_3 do
          FactoryGirl.create(:rate, :project => project_1)
        end

        its(:length) { should eq(2) }
        it { should include(rate_1.id,rate_3.id) }
        it { should_not include(rate_2.id) }
      end
    end

    describe 'item' do
      subject { ProjectReport.new(project_1).build_rate_report[rate_1.id] }

      describe 'keys' do
        it 'should have key :name' do
          expect(subject).to have_key(:name)
        end
        it 'should have key :hours' do
          expect(subject).to have_key(:hours)
        end
        it 'should have key :rate' do
          expect(subject).to have_key(:rate)
        end
        it 'should have key :cost' do
          expect(subject).to have_key(:cost)
        end
      end

      describe 'values' do
        let :total_hours do
          work_unit_1.hours + work_unit_2.hours
        end
        let :total_cost do
          rate_1.amount * total_hours
        end

        it 'should store rate name with key :name' do
          expect(subject[:name]).to eq(rate_1.name)
        end
        it 'should store rate amount with key :rate' do
          expect(subject[:rate]).to eq(rate_1.amount)
        end
        it 'should calculate and store user total hours with key :hours' do
          expect(subject[:hours]).to eq(total_hours)
        end
        it 'should calculate and store users total cost (rate * hours) with key :cost' do
          expect(subject[:cost]).to eq(total_cost)
        end
      end
    end
  end

  describe 'with decimal values for rates' do
    it "should have non-rounded values in the project report" do
      expect(ProjectReport.new(decimal_project).rates.first.amount).to eq(100.50)
    end
  end
end
