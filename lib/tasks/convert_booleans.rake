namespace :db do

  desc "Build the wall!!"
  task :convert_booleans => [
    :environment,
    :load_bool_queue,
    :create_temp_columns,
    :convert_column_values,
    :delete_old_columns,
    :rename_new_columns
  ]

  desc "The things to fix"
  task :load_bool_queue do
    @to_bool = {
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
  end

  desc "Create temporary columns"
  task :create_temp_columns => [:environment, :load_bool_queue] do
    @to_bool.each do |table, columns|
      columns.each do |column, options|
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
    p "Temporary columns 'name_new' created."
  end

  task :convert_column_values => [:environment, :load_bool_queue] do
    @to_bool.each do |table, columns|
      columns.each do |column, options|
        queries = [
          "UPDATE #{table} SET #{column}_new = true WHERE #{column} = 1;",
          "UPDATE #{table} SET #{column}_new = false WHERE #{column} = 0;"
        ]
        queries.each do |query|
          ActiveRecord::Base.connection.execute(query)
        end
      end
    end
    p "Integer values converted to booleans."
  end

  desc "Remove old columns"
  task :delete_old_columns => [:environment, :load_bool_queue] do

    @to_bool.each do |table, columns|
      columns.each do |column, options|
        query = "ALTER TABLE #{table} DROP COLUMN #{column};"
        ActiveRecord::Base.connection.execute(query)
      end
    end
    p "Original 'name' columns deleted."
  end

  desc "Rename temp columns to permanent name"
  task :rename_new_columns => [:environment, :load_bool_queue] do
    @to_bool.each do |table, columns|
      columns.each do |column, options|
        query = "ALTER TABLE #{table} RENAME COLUMN #{column}_new to #{column};"
        ActiveRecord::Base.connection.execute(query)
      end
    end
    p "Renaming columns from 'name_new' to 'name' complete"
  end


  desc "Remove temporary columns -- only used to reset database"
  task :delete_temp_columns => [:environment, :load_bool_queue] do

    @to_bool.each do |table, columns|
      columns.each do |column, options|
        query = "ALTER TABLE #{table} DROP COLUMN #{column}_new;"
        ActiveRecord::Base.connection.execute(query)
      end
    end
    p "Temporary columns removed."
  end

end
