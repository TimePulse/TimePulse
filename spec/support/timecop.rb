RSpec.configure do |config|
  config.before(:all) do
    Timecop.return
  end
end
