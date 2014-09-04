namespace :db do

  desc "Convert smallint to boolean datatypes, from MySQL transfer"
  task :create_bool_columns => :environment do
    to_bool = {
      :projects => {
        :clockable => {:null => false, :default => false},
        :billable => {:default => true},
        :flat_rate => {:default => false},
        :archived => {}
      },
      :users => {
        :inactive => {:default => false},
        :admin => {:default => false}
      },
      :work_units => {
        :billable => {}
      }
    }

    to_bool.each do |table, column|
      column.each do |column, options|
        query = "ALTER TABLE #{table} ADD COLUMN #{column}_new BOOLEAN"
        if options
          defaults = ""
          options.each do |option, value|
            if (option == :null && value == false)
              defaults += " NOT NULL"
            elsif option == :default
              defaults += " DEFAULT #{value}"
            end
          end
          query += defaults
        end
        query += ";"
        ActiveRecord::Base.connection.execute(query)
      end
    end
  end

end
