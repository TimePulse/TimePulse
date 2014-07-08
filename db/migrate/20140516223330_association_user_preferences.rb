class AssociationUserPreferences < ActiveRecord::Migration
  def change
    User.all.each do |u|
      up = UserPreferences.create!
      up.user = u
    end
  end
end
