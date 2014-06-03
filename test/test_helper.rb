TEST_ROOT_DIR = File.expand_path(File.dirname(__FILE__))

require 'active_support'
require 'active_record'
require 'action_controller'

require "pathname"
module Rails
  def self.env
    'test'
  end
  
  def self.root
    Pathname.new('/path/to/app')
  end
end

$:.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../rails/init', __FILE__)

require 'sqlite3'
require 'fileutils'

logdir = File.join(TEST_ROOT_DIR, 'log')
FileUtils.mkdir_p(logdir)
ActiveRecord::Base.logger = Logger.new File.join(logdir, 'test.log')
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

TMP_DIR = File.join(TEST_ROOT_DIR, 'tmp')

# Classes and methods to aid testing
Dir.glob(File.expand_path("../support/**/*.rb", __FILE__)).each { |file| require file }

$:.unshift File.expand_path('../', __FILE__)

require 'fixtures/models/attachment'
require 'fixtures/models/document'
require 'fixtures/models/options_stub'

# Mocha support for Peck
require 'mocha/api'

class Peck
  class Mocha
    include ::Mocha::API

    class AssertionCounter
      def initialize(spec)
        @spec = spec
      end

      def increment
        @spec.expectations << 'Mocha'
      end
    end

    def started_specification(spec)
      mocha_setup
    end

    def finished_specification(spec)
      mocha_verify(Peck::Mocha::AssertionCounter.new(spec))
      mocha_teardown
    end
  end
end

# Libraries for testing
require 'peck'
require 'peck/delegates'

# We need the Mocha delegate to receive events before the notifiers do
Peck.delegates << Peck::Mocha.new

require 'peck/counter'
require 'peck/context'
require 'peck/specification'
require 'peck/expectations'
require 'peck/notifiers/documentation'

Peck::Notifiers::Documentation.use
Peck.run_at_exit

Peck::Context.once do |context|
  include AttachmentSan::UploadHelpers

  context.before do
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
  end
end