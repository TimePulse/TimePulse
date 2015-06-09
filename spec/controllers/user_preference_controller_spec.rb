require "spec_helper"

describe UserPreferencesController do
  before do
    @user = authenticate(:user)
  end

  describe "PUT update" do
    it "User updating preferences" do
      put :update, :user_preferences => { :recent_projects_count => 6 }
      @user.reload.user_preferences.recent_projects_count.should == 6
    end
  end

end
