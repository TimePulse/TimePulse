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

require 'unsafe_mass_assignment'

def sometimes(prob = 0.5)
  if rand(1.0 < prob)
    yield
  end
end

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
        admin = User.unsafe_create!(
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
        Project.unsafe_create!(:name => 'root', :client => nil)
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

        user = User.unsafe_create!(
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
        Client.unsafe_create!(
          :name          => name,
          :abbreviation  => "CL#{i}",
          :billing_email => Faker::Internet.safe_email(name)
        )
      end
    end

    task :populate_projects => :environment do
      Client.all.each do |client|
        proj = Project.unsafe_create!(
          :client    => client,
          :name      => client.name,
          :clockable => false,
          :billable  => true,
          :parent    => Project.root
        )

        Project.unsafe_create!(:client => client, :name => 'Planning',    :clockable => true, :billable => true, :parent => proj)
        Project.unsafe_create!(:client => client, :name => 'Development', :clockable => true, :billable => true, :parent => proj)
        Project.unsafe_create!(:client => client, :name => 'Deployment',  :clockable => true, :billable => true, :parent => proj)
      end
    end

    task :populate_work_units do
      Project.where(:clockable => true).each do |project|
        User.where(admin: false).each do |user|
          if user.login == 'jane'
            unit_count = 500
          else
            unit_count = 50
          end

          unit_count.times do |i|
            length = rand(300).minutes
            days_ago = [2, rand(5)+(i/2)].max
            start_time = Time.now - days_ago.days - rand(10).hours

            wu = WorkUnit.unsafe_build(
              :user       => user,
              :project    => project,
              :start_time => start_time,
              :stop_time  => start_time + length,
              :notes      => Populator.words(0..6)
            )
            wu.clock_out!
          end
        end
      end
    end

    task :populate_rates do
      Project.where(:parent_id => Project.root.id).each do |project|
        User.where(admin: false).each_with_index do |user, i|
          Rate.unsafe_create!(
            :name => "Rate #{i}",
            :amount => 50 * i,
            :project => project,
            :users => [user]
          )
        end
      end
    end

    task :populate_bills do
      User.where(admin: false).each do |user|
        Bill.unsafe_create!(
          user: user,
          work_units: user.work_units.take(5)
        )
      end
    end

    task :populate_invoices => :environment do
      Client.all.each do |client|
        wus_by_month = WorkUnit.for_client(client).order("start_time ASC").group_by{ |wu| wu.start_time.strftime("%Y%B") }

        wus_by_month.each do |month, work_units|
          Invoice.unsafe_create!(
            client: client,
            work_units: work_units
          )
        end
      end

    end

  end
end
