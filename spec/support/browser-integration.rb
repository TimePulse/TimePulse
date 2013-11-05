require 'capybara/rspec'
#require 'selenium-webdriver'
require 'rspec-steps'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :inspector => true, :phantomjs_options => %w{--load-images=false})
end
Capybara.default_driver = :poltergeist

# uncomment to enable in-browser testing
# Capybara.default_driver = :selenium-webdriver

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
