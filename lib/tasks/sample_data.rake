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

class Array
  # If +number+ is greater than the size of the array, the method
  # will simply return the array itself sorted randomly
  # defaults to picking one item
  def pick(number = 1)
    if (number == 1)
      sort_by{ rand }[0]
    else
      sort_by{ rand }.slice(0...number)
    end
  end
end

require 'unsafe_mass_assignment'

namespace :db do
  namespace :sample_data do

    desc "Fill the database with sample data for demo purposes"
    task :load => [
      :environment,
      :populate_users,
      :populate_clients_and_projects,
      :populate_work_units,
      :populate_rates
      ]

    task :reload => [ :clear, :load ]

    task :clear => :environment do
      User.delete_all
      Client.delete_all
      Project.delete_all
      Rails.cache.clear
    end


    # Load users
    task :populate_users => :environment do
      5.times do |i|
        generic_user = User.unsafe_create!(:login => "user#{i}",
                            :name => "User #{i}",
                            :email => "user#{i}@example.com",
                            :password => 'password',
                            :password_confirmation => 'password')
        generic_user.confirm!
      end
    end

    task :populate_clients_and_projects => :environment do

      4.times do |nn|
        client = Client.unsafe_create!(
          :name => "Client #{nn}",
          :abbreviation => "CL#{nn}",
          :billing_email => "client_#{nn}@example.com"
        )
        proj = Project.unsafe_create!(
          :client => client,
          :name => client.name,
          :clockable => false,
          :billable => true,
          :parent => Project.root
        )
        Project.unsafe_create!(:client => client, :name => 'Planning',    :clockable => true, :billable => true, :parent => proj)
        Project.unsafe_create!(:client => client, :name => 'Development', :clockable => true, :billable => true, :parent => proj)
        Project.unsafe_create!(:client => client, :name => 'Deployment',  :clockable => true, :billable => true, :parent => proj)
      end
    end

    task :populate_work_units do
      projects = Project.where(:clockable => true).to_a
      User.all.each do |user|
        (10..20).each do |nn|
          wu = WorkUnit.unsafe_build(
            :user => user,
            :project => projects.pick,
            :start_time => Time.now - nn.days - nn.hours,
            :stop_time => Time.now - nn.days - nn.hours + 45.minutes,
            :notes => Populator.words(2..6)
          )
          wu.clock_out!
        end
      end
    end

    task :populate_rates do
      project = Project.where(:parent_id => Project.root.id).first
      project.rates << Rate.unsafe_create!(:name => 'Rate 1', :amount => 100, :users => [User.first])
    end

    # An example to be deleted or replaced
    task :populate_some_table => :environment do
      require 'populator'
      SomeTable.delete_all

      10.times do
        SomeTable.unsafe_create!(
          :field => Populator.words(4..8),
          :date => Date.today - rand(365).days,
          :url => "http://" + Faker::Internet.domain_name
        )
      end
    end

  end
end

# Do something sometimes (with probability p).
def sometimes(p, &block)
  yield(block) if rand <= p
end
