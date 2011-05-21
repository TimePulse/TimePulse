module RSpec::Core
  module Stepwise
    def suspend_transactional_fixtures
      old_val = self.use_transactional_fixtures
      self.use_transactional_fixtures = false

      yield

      self.use_transactional_fixtures = old_val
    end

    def run_examples(reporter)
      instance = new
      set_ivars(instance, before_all_ivars)

      suspend_transactional_fixtures do
        filtered_examples.inject(true) do |success, example|
          break if RSpec.wants_to_quit 
          unless success
            reporter.example_started(example)
            example.metadata[:pending] = true
            example.metadata[:execution_result][:pending_message] = "Previous step failed"
            example.metadata[:execution_result][:started_at] = Time.now
            example.instance_eval{ record_finished :pending, :pending_message => "Previous step failed" }
            reporter.example_pending(example)
            next
          end
          succeeded = example.run(instance, reporter)
          RSpec.wants_to_quit = true if fail_fast? && !succeeded
          success && succeeded
        end
      end
    end
  end

  class ExampleGroup
    def self.steps(*args, &example_group_block)
      group = describe(*args, &example_group_block)
      group.extend Stepwise
      group
    end
  end

  module ObjectExtensions
    def steps(*args, &example_group_block)
      args << {} unless args.last.is_a?(Hash)
      RSpec::Core::ExampleGroup.steps(*args, &example_group_block).register
    end
  end
end
