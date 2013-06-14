module DatabaseConfig
  def read(db = (ENV['RAILS_ENV'] || 'development'))
    database = YAML::load_file('config/database.yml')
    return database["#{db}"]
  end
  module_function :read
end

