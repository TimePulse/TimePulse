require 'spec_helper'

describe UserPreferences do
  let! :user       do FactoryGirl.create(:user) end
  let! :preference do UserPreferences.create!( :user_id => user.id ) end

  it 'should have user with user_preferences' do
    user.user_preferences.user_id.should == preference.user_id
  end
end