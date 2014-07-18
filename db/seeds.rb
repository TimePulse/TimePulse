# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


User.reset_column_information

admin = User.find_or_create_by!(:login => 'admin') do |user|
  user.login = 'admin'
  user.name = "Admin"
  user.email = "admin@timepulse.io"
  user.password = 'foobar'
  user.password_confirmation = 'foobar'
  user.admin = true
  user.create_user_preferences!
end
admin.confirm!

Project.find_or_create_by!(:name => 'root', :client => nil)
