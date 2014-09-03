require 'bibliotech/rake_lib'

puts "\n#{__FILE__}:#{__LINE__} => #{:here.inspect}"
begin
  BiblioTech::Tasklib.new
rescue
  p $!
end
