require 'spec_helper'

describe ProjectReport do

	describe '#work_units_by_user' do
		let! :work_unit do
			FactoryGirl.create(:work_unit, 
				:user_id => user.id, 
				:project_id => project.id, 
				:billable => true, 
				:invoice_id => nil
			)
		end		

		let :user do 
			FactoryGirl.create(:user)
		end

		let :rates_user do 
			FactoryGirl.create(:rates_user, :rate => rate, :user => user)
		end

		let :project do
			FactoryGirl.create(:project)
		end

		let :rate do
			FactoryGirl.create(:rate)
		end


		describe 'rows' do
			subject do
				ProjectReport.new(project)
			end

			it 'should return related work units' do
				subject.work_units.should include(work_unit)
			end			
			it 'should not return unrelated work units' do
				unrelated_project = FactoryGirl.create(:project)
				work_unit_unrelated = FactoryGirl.create(:work_unit, :project_id => unrelated_project.id)
				subject.work_units.should_not include(work_unit_unrelated)
			end

			xit 'should include user name' do
				expect(subject[0]).to eq(user.name)
			end
			xit 'should return total hours for user on project' do
				expect(subject[1]).to eq(28.50)
			end
			xit 'should return total cost for user on project by hourly rate' do
				expect(subject[2]).to eq(2850.00)
			end
		end
		
		xit 'should wrap values for each user' do
		end
	end
end