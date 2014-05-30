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

namespace :db do
  namespace :sample_data do

    desc "Fill the database with sample data for demo purposes"
    task :load => [
        :environment,
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
    task :reload => [ :clear, :create_admin, :create_root_project, :load ]

    task :clear => :environment do
      User.delete_all
      UserPreferences.delete_all
      Client.delete_all
      Project.delete_all
      WorkUnit.delete_all
      Rate.delete_all
      RatesUser.delete_all

      Activity.delete_all
      Bill.delete_all
      Invoice.delete_all
      InvoiceItem.delete_all

      Rails.cache.clear
    end

    # create_admin and create_root_project are here in case reload is called
    # maybe call seed task after clear instead?
    task :create_admin => :environment do
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
    task :create_root_project => :environment do
      Project.unsafe_create!(:name => 'root', :client => nil)
    end

    task :populate_users => :environment do
      5.times do |i|
        name = Faker::Name.name
        user = User.unsafe_create!(
          :name                  => name,
          :login                 => Faker::Internet.user_name(name),
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
          2.times do |i|
            wu = WorkUnit.unsafe_build(
              :user       => user,
              :project    => project,
              :start_time => Time.now - (i + 1 * 10).days - (i + 1 * 10).hours,
              :stop_time  => Time.now - (i + 1 * 10).days - (i + 1 * 10).hours + 45.minutes,
              :notes      => Populator.words(2..6)
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

    task :populate_invoices do
      Client.all.each do |client|
        Invoice.unsafe_create!(
          client: client,
          work_units: client.projects.first.children.first.work_units.to_a.take(5)
        )
      end
    end

  end
end
