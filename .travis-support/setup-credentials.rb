#!/usr/bin/env ruby

def run(creds_csv)
  %w{AMAZON_ACCESS_KEY_ID AMAZON_SECRET_ACCESS_KEY}.zip(File::read(creds_csv).lines.last.split(",")[1..-1]).each do |key, value|
    %x"echo #{key}=#{value} | travis encrypt --org --add" #Perfect world: spawn the travis, pipe the secrets in
  end
  puts "You need to add '- AMAZON_S3_BUCKET=lrd-travis-caching' to .travis.yml"
  puts "You also need to add an 'install: .travis-support/cached-bundle install --deployment' to .travis.yml"
end

run(*ARGV)
