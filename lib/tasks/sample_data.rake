# NOTE:   This task exists to create fake data for the purposes of
# demonstrating the site to a client during development.   So whatever
# scaffolds we create should get a method in here to generate some
# fake entries.   Most of it should be lipsum.

# IT SHOULD NOT CONTAIN nay data absolutely required for the site to work,
#   especially that we might need in testing.  For example, groups for 'users'
#   and 'admins' if we are using an authorization system.   Such things should
#   go in db/seeds.rb.
#
# Once the client has real data ... i.e. an initial set of pages and/or
# a menu/location tree, those should replace the lorem data.


def sometimes(prob = 0.5)
  if rand(1.0 < prob)
    yield
  end
end

def pick_from(array)
  array[rand(array.length)]
end


#require 'benchmark'

#class Rake::Task
  #def execute_with_benchmark(*args)
    #bench = Benchmark.measure do
      #execute_without_benchmark(*args)
    #end
    #puts "  #{name} --> #{bench}"
  #end
  #alias_method_chain :execute, :benchmark
#end

namespace :db do
  namespace :sample_data do

    desc "Fill the database with sample data for demo purposes"
    task :load => [
        :environment,
        :create_admin,
        :create_root_project,
        :populate_users,
        :populate_user_preferences,
        :populate_clients,
        :populate_projects,
        :populate_work_units,
        :populate_rates,
        :populate_bills,
        :populate_invoices
      ]

    desc "Reload sample data for demo purposes"
    task :reload => [ :clear, :load ]

    task :clear => :environment do
      User.delete_all
      UserPreferences.delete_all
      Client.delete_all
      Project.delete_all
      WorkUnit.delete_all
      Rate.delete_all
      RatesUser.delete_all
      Bill.delete_all
      Invoice.delete_all
      InvoiceItem.delete_all

      Activity.delete_all

      Rails.cache.clear
    end

    task :create_admin => :environment do
      if User.where(admin: true).empty?
        admin = User.create!(
          :login                 => 'admin',
          :name                  => "Admin",
          :email                 => "admin@timepulse.io",
          :password              => 'foobar',
          :password_confirmation => 'foobar'
        )
        admin.admin = true
        admin.save
        admin.confirm!
      end
    end

    task :create_root_project => :environment do
      unless Project.root
        Project.create!(:name => 'root', :client => nil)
      end
    end

    task :populate_users => :environment do
      5.times do |i|
        if i == 0
          name = "Jane Doe"
          login = 'jane'
        else
          name = Faker::Name.name
          login = Faker::Internet.user_name(name)
        end

        user = User.create!(
          :name                  => name,
          :login                 => login,
          :email                 => Faker::Internet.safe_email(name),
          :password              => DEFAULT_PASSWORD,
          :password_confirmation => DEFAULT_PASSWORD
        )
        user.confirm!
      end
    end

    task :populate_user_preferences => :environment do
      User.all.each do |user|
        up = UserPreferences.create!
        up.user = user
        up.save
      end
    end

    task :populate_clients => :environment do
      5.times do |i|
        name = Faker::Company.name
        Client.create!(
          :name          => name,
          :abbreviation  => "CL#{i}",
          :billing_email => Faker::Internet.safe_email(name)
        )
      end
    end

    task :populate_projects => :environment do
      Client.all.each do |client|
        proj = Project.create!(
          :client    => client,
          :name      => client.name,
          :clockable => false,
          :billable  => true,
          :parent    => Project.root
        )

        Project.create!(:client => client, :name => 'Planning',    :clockable => true, :billable => true, :parent => proj)
        Project.create!(:client => client, :name => 'Development', :clockable => true, :billable => true, :parent => proj)
        Project.create!(:client => client, :name => 'Deployment',  :clockable => true, :billable => true, :parent => proj)
      end
    end

    task :populate_work_units do
      projects = Project.where(:clockable => true).to_a
      users = User.where(admin: false).to_a

      BusinessTime::Config.beginning_of_workday = "9:30am"
      BusinessTime::Config.end_of_workday = "6:00pm"

      users.each do |user|
        start = Time.beginning_of_workday(80.business_days.ago)
        this_morning = Time.now.beginning_of_day

        until (start > this_morning) do
          s_t = start + rand(5).minutes
          if Time.after_business_hours?(s_t)
            start = Time.roll_forward(start) # go to the next business_day
            next
          end
          hours = rand() * 3  # work units from 0 to 3 hours
          e_t = s_t + hours.hours
          wu = user.work_units.create(
            :project => pick_from(projects),
            :start_time => s_t,
            :stop_time => e_t,
            :hours     => hours,
          )
          if wu.persisted?
            wu.activities.create(
              :project => wu.project,
              :user => user,
              :source => "User",
              :action => "Annotation",
              :description => Populator.words(0..6),
              :time => wu.stop_time
              )
          end
          start = e_t
        end
      end
    end

    task :populate_rates do
      Project.where(:parent_id => Project.root.id).each do |project|
        User.where(admin: false).each_with_index do |user, i|
          Rate.create!(
            :name => "Rate #{i += 1}",
            :amount => (50 * i),
            :project => project,
            :users => [user]
          )
        end
      end
    end

    task :populate_bills do
      User.where(admin: false).each do |user|
        Bill.create!(
          user: user,
          work_units: user.work_units.take(5)
        )
      end
    end

    task :populate_invoices => :environment do
      Client.all.each do |client|
        wus_by_month = WorkUnit.for_client(client).order("start_time ASC").group_by{ |wu| wu.start_time.strftime("%Y%B") }

        wus_by_month.each do |month, work_units|
          Invoice.create!(
            client: client,
            work_units: work_units
          )
        end
      end

    end

  end
end
