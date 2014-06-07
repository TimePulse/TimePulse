require 'capybara/rspec'
#require 'selenium-webdriver'
require 'rspec-steps'
require 'capybara/poltergeist'
require 'stringio'


module Capybara::Poltergeist
  class Client
    private
    def redirect_stdout
      prev = STDOUT.dup
      prev.autoclose = false
      $stdout = @write_io
      STDOUT.reopen(@write_io)

      prev = STDERR.dup
      prev.autoclose = false
      $stderr = @write_io
      STDERR.reopen(@write_io)
      yield
    ensure
      STDOUT.reopen(prev)
      $stdout = STDOUT
      STDERR.reopen(prev)
      $stderr = STDERR
    end
  end
end
class WarningSuppressor
  class << self
    def write(message)
      if message =~ /QFont::setPixelSize: Pixel size <= 0/ || message =~/CoreText performance note:/ then 0 else puts(message);1;end
    end
  end
end

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    :inspector => true,
    :phantomjs_logger => StringIO.new,
    :phantomjs_options => %w{--load-images=true},
    :timeout => 180)
end

Capybara.default_driver = (ENV['CAPYBARA_DRIVER'] || :poltergeist_debug).to_sym
# uncomment to enable in-browser testing
# Capybara.default_driver = :selenium

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

module BrowserTools
  def accept_alert
    if poltergeist?
      # do nothing ... really?
      # https://github.com/jonleighton/poltergeist/issues/50
      # Poltergeist's behavior is to return true to window.alert
      # Does mean it's a challenge to test cancelling e.g. deletes, or
      # confirming that an alert happens even
    else
      alert = page.driver.browser.switch_to.alert
      alert.accept
    end
  end

  #renders the xpath to properly match a css class (or other space separated
  #attribute)
  #Use like: div[#{attr_includes("class", "findme")}]
  #
  def attr_includes(attr, value)
    "contains(concat(' ', normalize-space(@#{attr}), ' '), ' #{value} ')"
  end

  def class_includes(value)
    attr_includes("class", value)
  end

  def wait_for_animation
    sleep(1) if poltergeist?
  end

  def poltergeist?
    Capybara.javascript_driver.to_s =~ /poltergeist/
  end

  def self.warnings
    @warnings ||= {}
  end

  def self.warn(general, specific=nil)
    warnings.fetch(general) do
      warnings[general] = true
      puts "Warning: #{general}#{specific ? ": #{specific}" : ""}"
    end
  end

  def frame_index(dir)
    @frame_dirs ||= Hash.new do |h,k|
      FileUtils.rm_rf(k)
      FileUtils.mkdir_p(k)
      h[k] = 0
    end
    @frame_dirs[dir] += 1
  end

  def save_snapshot(dir, name)
    require 'fileutils'

    dir = "tmp/#{dir}"

    path = "#{dir}/#{"%03i" % frame_index(dir)}-#{name}.png"
    page.driver.save_screenshot(path, :full => true)

    yield path if block_given?
  rescue Capybara::NotSupportedByDriverError => nsbde
    BrowserTools.warn("Can't use snapshot", nsbde.inspect)
  end

  def snapshot(dir)
    save_snapshot(dir, "debug") do |path|
      msg = "Saved screenshot: #{path} (from: #{caller[0].sub(/^#{Dir.pwd}/,'')})"
      puts msg
      Rails.logger.info(msg)
    end
  end
end

module SnapStep
  def self.included(steps)
    steps.after(:step) do
      save_snapshot(example.metadata[:snapshots_into], example.description.downcase.gsub(/\s+/, "-"))
    end
  end
end

RSpec.configure do |config|
  config.include BrowserTools, :type => :feature

  config.include SnapStep, :snapshots_into => proc{|v| v.is_a? String}
end
