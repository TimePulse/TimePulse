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

Permission.create(:group  =>  guest,      :controller  =>  "user_sessions",  :action  =>  "new")
Permission.create(:group  =>  reg_users,  :controller  =>  "user_sessions",  :action  =>  "destroy")
Permission.create(:group  =>  reg_users,  :controller  =>  "current_project")
Permission.create(:group  =>  reg_users,  :controller  =>  "home")
Permission.create(:group  =>  reg_users,  :controller  =>  "clock_time")
Permission.create(:group  =>  reg_users,  :controller  =>  "work_units",  :action  =>  "show")
Permission.create(:group  =>  reg_users,  :controller  =>  "work_units",  :action  =>  "new")

