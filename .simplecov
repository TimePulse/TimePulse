require 'cadre/simplecov'

SimpleCov.start 'rails' do
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Cadre::SimpleCov::VimFormatter
  ]
  #add_filter "./spec"
end
