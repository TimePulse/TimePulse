require 'spec_helper'

describe ProjectReport, type: :presenter do

  let :project_1 do FactoryGirl.create(:project) end
  let :project_2 do FactoryGirl.create(:project) end
  let :user_1 do FactoryGirl.create(:user) end
  let :user_2 do FactoryGirl.create(:user) end
  let :user_3 do FactoryGirl.create(:user) end
  let! :rates_user_1 do FactoryGirl.create(:rates_user, :rate => project_1.rates.last, :user => user_1) end
  let! :rates_user_2 do FactoryGirl.create(:rates_user, :rate => project_1.rates.last, :user => user_2) end
  let! :rates_user_3 do FactoryGirl.create(:rates_user, :rate => project_2.rates.last, :user => user_3) end
  let! :work_unit_1 do FactoryGirl.create(:work_unit, :project => project_1, :user => user_1) end
  let! :work_unit_2 do FactoryGirl.create(:work_unit, :project => project_1, :user => user_1) end

  describe '#users' do
    subject { ProjectReport.new(project_1).users }

    it { should include(user_1) }
    it { should_not include(user_2, user_3) }
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

    describe 'user rows' do
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
          expect(subject[:rate].to_i).to eq(project_rate)
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
end