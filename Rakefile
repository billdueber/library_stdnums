# encoding: utf-8
require "bundler/gem_tasks"

require 'yard'
YARD::Rake::YardocTask.new
task :doc => :yard

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.libs << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

task :default => :test
task :spec => :test
