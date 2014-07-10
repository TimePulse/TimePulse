require 'spec_helper'

describe ProjectReport do

	let! :work_unit do
		FactoryGirl.create(:work_unit, 
			:user_id => user.id, 
			:project_id => project.id, 
			:billable => true, 
			:invoice_id => nil
		)
	end		
	let :user do FactoryGirl.create(:user) end
	let :project do FactoryGirl.create(:project) end
	let! :rates_user do FactoryGirl.create(:rates_user, :rate => project.rates.last, :user => user) end

	describe '#work_units' do
		subject do
			ProjectReport.new(project).work_units
		end

		it 'should return related work units' do
			subject.should include(work_unit)
		end			
		it 'should not return unrelated work units' do
			unrelated_project = FactoryGirl.create(:project)
			work_unit_unrelated = FactoryGirl.create(:work_unit, :project_id => unrelated_project.id)
			subject.should_not include(work_unit_unrelated)
		end
	end

	describe '#build_user_report' do
		subject do
			ProjectReport.new(project).build_user_report
		end

		xit 'should index row with key userid' do
			expect(subject[user.id]).to eq(2)
		end

		describe 'row' do
			subject do
				ProjectReport.new(project).build_user_report[user.id]
			end

			it 'should store users name with key "Name"' do
				expect(subject["Name"]).to eq(user.name)
			end				
			it 'should store users total hours with key "Hours"' do
				expect(subject["Hours"]).to eq(9.5)
			end				
			it 'should store users rate with key "Rate"' do
				expect(subject["Rate"]).to eq(100)
			end
			it 'should store users total cost (rate * hours) with key "Cost"' do
				expect(subject["Cost"]).to eq(950)
			end
		end
	end
end