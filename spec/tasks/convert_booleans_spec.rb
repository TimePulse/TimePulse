require 'spec_helper'
require 'rake'

describe 'db:convert_to_boolean namespace rake task', :type => :task do

  steps 'db:create_temp_columns' do

    before do
      load File.expand_path("../../../lib/tasks/convert_booleans.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task.define_task(:to_bool)
    end

    it 'should succeed' do
      Rake::Task["db:create_temp_columns"].reenable
      Rake::Task["db:create_temp_columns"].invoke
    end

    describe Project do
      it {should have_db_column(:clockable_new).of_type(:boolean).with_options(default: false, null: false)}
      it {should have_db_column(:billable_new).of_type(:boolean).with_options(default: true)}
      it {should have_db_column(:flat_rate_new).of_type(:boolean).with_options(default: false)}
      it {should have_db_column(:archived_new).of_type(:boolean)}
    end

    describe User do
      it {should have_db_column(:inactive_new).of_type(:boolean).with_options(default: false)}
      it {should have_db_column(:admin_new).of_type(:boolean).with_options(default: false)}
    end

    describe WorkUnit do
      it {should have_db_column(:billable_new).of_type(:boolean)}
    end
  end

  steps 'db:convert_columns' do
    # before do
    #   load File.expand_path("../../../lib/tasks/convert_booleans.rake", __FILE__)
    #   Rake::Task.define_task(:environment)
    # end
    # it 'should succeed' do
    #   Rake::Task["db:create_temp_columns"].reenable
    #   Rake::Task["db:create_temp_columns"].invoke
    # end

  end

  steps 'db:delete_temp_columns' do

    before do
      load File.expand_path("../../../lib/tasks/convert_booleans.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task.define_task(:to_bool)
    end

    it 'should succeed' do
      Rake::Task["db:delete_temp_columns"].reenable
      Rake::Task["db:delete_temp_columns"].invoke
    end

    describe Project do
      it {should_not have_db_column(:clockable_new)}
      it {should_not have_db_column(:billable_new)}
      it {should_not have_db_column(:flat_rate_new)}
      it {should_not have_db_column(:archived_new)}
    end

    describe User do
      it {should_not have_db_column(:inactive_new)}
      it {should_not have_db_column(:admin_new)}
    end

    describe WorkUnit do
      it {should_not have_db_column(:billable_new)}
    end
  end
end
