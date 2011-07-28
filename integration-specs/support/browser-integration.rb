require 'capybara/rspec'
require 'selenium-webdriver'
require 'rspec-steps'

Capybara.register_driver(:selenium_chrome) do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.default_driver = :selenium

module SaveAndOpenOnFail
  def instance_eval(&block)
    super(&block)
  rescue Object => ex
    wrapper = ex.exception("#{ex.message}\nLast view at: file://#{save_page}")
    wrapper.set_backtrace(ex.backtrace)
    raise wrapper
  end
end

module HandyXPaths
  class Builder <  XPath::Expression::Self
    include RSpec::Core::Extensions::InstanceEvalWithArgs
  end

  def make_xpath(*args, &block)
    xpath = Builder.new
    unless block.nil?
      xpath.instance_eval_with_args(*args, &block)
    end
    return xpath
  end
end
