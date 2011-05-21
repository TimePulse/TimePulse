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


namespace :db do
  namespace :sample_data do

    desc "Fill the database with sample data for demo purposes"
    task :load => [
      :environment
      # populate_some_table,
      # populate_populate_other_table,
      ]

    # An example to be deleted or replaced
    task :populate_some_table => :environment do
      require 'populator'
      SomeTable.delete_all

      10.times do
        SomeTable.create(
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

