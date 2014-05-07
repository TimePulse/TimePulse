require "spec_helper"

describe WorkUnitSerializer do
  let :work_unit do
    FactoryGirl.build_stubbed(
      :work_unit
    )
  end

  describe 'as_json' do
    subject :json do
      WorkUnitSerializer.new(work_unit).to_json
    end

    it { should be_present }
    it { should have_json_path('work_unit/id') }
    it { should have_json_path('work_unit/start_time') }
    it { should have_json_path('work_unit/stop_time') }
    it { should have_json_path('work_unit/hours') }
    it { should have_json_path('work_unit/notes') }
    it { should have_json_path('work_unit/billable') }
  end
end