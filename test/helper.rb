TEST_ROOT_DIR = File.dirname(__FILE__)

$:.unshift File.join(TEST_ROOT_DIR, '/../lib')
$:.unshift File.join(TEST_ROOT_DIR, '/lib')

ENV['RAILS_ENV'] = 'test'

require 'rubygems' rescue LoadError
require 'active_record'

require 'init'

require 'sqlite3'
require 'bacon'

ActiveRecord::Base.logger = Logger.new File.join(TEST_ROOT_DIR, '/log/test.log')
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => File.join(TEST_ROOT_DIR, '/db/test.db'))

require 'schema'
require 'attachments'
require 'upload_helpers'