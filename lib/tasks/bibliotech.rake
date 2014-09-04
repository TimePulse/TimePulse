require 'bibliotech/rake_lib'

begin
  BiblioTech::Tasklib.new
rescue
  p $!
end
