require "spec_helper"

describe CalendarEventSerializer do
  let :work_unit do
    FactoryGirl.build_stubbed(
      :work_unit
    )
  end

  describe 'as_json' do
    subject :json do
      CalendarEventSerializer.new(work_unit).to_json
    end

    it { should be_present }
    it { should have_json_path('id') }
    it { should have_json_path('className') }
    it { should have_json_path('title') }
    it { should have_json_path('start') }
    it { should have_json_path('end') }

  end
end