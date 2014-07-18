class AssociateUserPreferences < ActiveRecord::Migration
  def change
    UserPreferences.where(:user_id => nil).destroy_all

    User.all.each do |user|
      user.create_user_preferences!
    end
  end
end
