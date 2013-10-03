require 'capybara/rspec'
require 'selenium-webdriver'
require 'rspec-steps'
require 'capybara/poltergeist'


Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :inspector => true, :phantomjs_options => %w{--load-images=false})
end
Capybara.default_driver = :poltergeist

module SaveAndOpenOnFail
  def instance_eval(&block)
    super(&block)
  rescue RSpec::Core::Pending::PendingDeclaredInExample
    raise
  rescue Object => ex
    begin
      wrapper = ex.exception("#{ex.message}\nLast view at: file://#{save_page}")
      wrapper.set_backtrace(ex.backtrace)
      raise wrapper
    rescue
      raise ex
    end
  end
end

module BrowserHelpers
  def snapshot(dir)
    require 'fileutils'

    dir = "tmp/#{dir}"

    @frame_dirs ||= Hash.new do |h,k|
      puts "Clearing #{k}"
      FileUtils.rm_rf(k)
      FileUtils.mkdir_p(k)
      h[k] = 0
    end
    frame = (@frame_dirs[dir] += 1)

    path = "#{dir}/#{"%03i" % frame}.png"
    msg = "Saving screenshot: #{path} (from: #{caller[0]})"
    puts msg
    Rails.logger.info(msg)
    page.driver.save_screenshot(path, :full => true)
  rescue Capybara::NotSupportedByDriverError
  end
end
=begin

module HandyXPaths
  class Builder <  XPath::Expression::Self
    include XPath::HTML
    include RSpec::Core::Extensions::InstanceEvalWithArgs
  end

  module Attrs
    def attrs(hash)
      all(*hash.map do |name, value|
        XPath.attr(name) == value
      end)
    end

    def all(*expressions)
      expressions.inject(current) do |chain, expression|
        chain.where(expression)
      end
    end
  end

  def make_xpath(*args, &block)
    xpath = Builder.new
    unless block.nil?
      xpath = xpath.instance_eval_with_args(*args, &block)
    end
    return xpath
  end
end

module XPath
  include HandyXPaths::Attrs
  extend HandyXPaths::Attrs
end

class XPath::Expression
  include HandyXPaths::Attrs
end
=end
