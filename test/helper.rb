TEST_ROOT_DIR = File.expand_path(File.dirname(__FILE__))

frameworks = %w(activesupport activerecord actionpack)

rails = [
  File.expand_path('../../../rails', TEST_ROOT_DIR),
  File.expand_path('../../rails', TEST_ROOT_DIR)
].detect do |possible_rails|
  begin
    entries = Dir.entries(possible_rails)
    frameworks.all? { |framework| entries.include?(framework) }
  rescue Errno::ENOENT
    false
  end
end

raise "Couldn't find Rails directory!" unless rails

frameworks.each { |framework| $:.unshift(File.join(rails, framework, 'lib')) }
$:.unshift File.join(TEST_ROOT_DIR, '/../lib')
$:.unshift File.join(TEST_ROOT_DIR, '/lib')

ENV['RAILS_ENV'] = 'test'

# Rails libs
begin
  require 'active_support'
  require 'active_record'
  require 'action_controller'
rescue LoadError
  raise "Please install Attachment-San as Rails plugin before running the tests."
end

require File.expand_path('../../rails/init', __FILE__)

# Libraries for testing
require 'rubygems' rescue LoadError
require 'sqlite3'
require 'test/spec'
require 'mocha'
require 'fileutils'

logdir = File.join(TEST_ROOT_DIR, 'log')
FileUtils.mkdir_p(logdir)
ActiveRecord::Base.logger = Logger.new File.join(logdir, 'test.log')

dbdir = File.join(TEST_ROOT_DIR, 'db')
FileUtils.mkdir_p(dbdir)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

# Classes and methods to aid testing
require 'schema'
require 'attachments'
require 'upload_helpers'
