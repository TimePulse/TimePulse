require 'spec_helper'

describe WorkUnitFixerController do
  before(:each) do
    @user = authenticate(:admin)
    @work_unit = FactoryGirl.create(:in_progress_work_unit)
    @work_unit.hours = 9.00
    @work_unit.save(:validate => false)
  end

  describe "#create" do
    it "should redirect back" do
      post :create, :id => @work_unit.id
      response.should redirect_back
    end

    it "should fix the work unit stop time" do
      lambda do
        post :create, :id => @work_unit.id
        @work_unit.reload
      end.should change{ @work_unit.stop_time.to_s }.from("").to((@work_unit.start_time + @work_unit.hours.hours).to_s)
    end

    it "should set an instance variable for the work_unit to fix" do
      post :create, :id => @work_unit.id
      assigns[:work_unit].should == @work_unit
    end

    describe "for javascript requests" do
      render_views
      before(:each) { request.accept = "application/javascript" }

      it "should respond by replacing the contents of #project_picker" do
        post :create, :id => @work_unit.id
        response.content_type.should == "text/javascript"
      end
    end
  end
end
