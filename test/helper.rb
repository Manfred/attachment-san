TEST_ROOT_DIR = File.dirname(__FILE__)

$:.unshift File.join(TEST_ROOT_DIR, '/../lib')
$:.unshift File.join(TEST_ROOT_DIR, '/lib')

ENV['RAILS_ENV'] = 'test'

# Rails libs
require 'rubygems' rescue LoadError
require 'active_record'
require 'action_controller'

require 'init'

# Libraries for testing
require 'sqlite3'
require 'mocha'
require 'bacon'

ActiveRecord::Base.logger = Logger.new File.join(TEST_ROOT_DIR, '/log/test.log')
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => File.join(TEST_ROOT_DIR, '/db/test.db'))

# Classes and methods to aid testing
require 'schema'
require 'attachments'
require 'upload_helpers'