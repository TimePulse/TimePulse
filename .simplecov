require 'cadre/simplecov'
require 'code_climate/test_reporter/formatter'

SimpleCov.start 'rails' do
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Cadre::SimpleCov::VimFormatter,
    CodeClimate::TestReporter::Formatter
  ]
  #add_filter "./spec"
end
