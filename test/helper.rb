TEST_ROOT_DIR = File.dirname(__FILE__)

%w(activerecord actionpack).each do |d|
  $:.unshift File.expand_path(File.join(TEST_ROOT_DIR, "/../../../rails/#{d}/lib"))
end
$:.unshift File.join(TEST_ROOT_DIR, '/../lib')
$:.unshift File.join(TEST_ROOT_DIR, '/lib')

ENV['RAILS_ENV'] = 'test'

# Rails libs
begin
  require 'active_record'
  require 'action_controller'
rescue LoadError
  raise "Please install Attachment-San as Rails plugin before running the tests."
end

require 'init'

# Libraries for testing
require 'rubygems' rescue LoadError
require 'sqlite3'
require 'mocha'
require 'bacon'
require 'fileutils'

logdir = File.join(TEST_ROOT_DIR, 'log')
FileUtils.mkdir_p(logdir)
ActiveRecord::Base.logger = Logger.new File.join(logdir, 'test.log')
dbdir = File.join(TEST_ROOT_DIR, 'db')
FileUtils.mkdir_p(dbdir)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => File.join(dbdir, 'test.db'))

# Classes and methods to aid testing
require 'schema'
require 'attachments'
require 'upload_helpers'
