# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

reg_users = Group.create(:name => "Registered Users")
admin = Group.create(:name => "Administration")
guest = Group.create(:name => "Guest")

Permission.create(:group_id  =>  guest.id,      :controller  =>  "user_sessions",    :action  =>  "new")
Permission.create(:group_id  =>  reg_users.id,  :controller  =>  "user_sessions",    :action  =>  "destroy")
Permission.create(:group_id  =>  reg_users.id,  :controller  =>  "current_project")
Permission.create(:group_id  =>  reg_users.id,  :controller  =>  "home")
Permission.create(:group_id  =>  reg_users.id,  :controller  =>  "clock_time")
Permission.create(:group_id  =>  reg_users.id,  :controller  =>  "work_units",       :action  =>  "show")
Permission.create(:group_id  =>  reg_users.id,  :controller  =>  "work_units",       :action  =>  "new")

Project.create(:name => 'root', :client => nil)