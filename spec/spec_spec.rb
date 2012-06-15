require 'spec_helper'

describe "spec filesystem" do
  it "should not contain any spec files that don't end in _spec.rb" do
    %w{ models helpers controllers routing 00_stories views}.each do |dir|
      files = Dir.glob(File.join('spec',dir,'**/*.rb'))
      files.each do |file|
        file.should =~ /_spec.rb$/
      end
    end
  end
end
