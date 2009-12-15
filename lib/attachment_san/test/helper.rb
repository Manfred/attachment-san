require 'test/unit'
require 'tempfile'
require 'fileutils'

module AttachmentSan
  ##
  #
  # This module is included in the Test:Unit::TestCase class, making it
  # available as instance methods in your test case.
  #
  module UploadHelpers
    ##
    #
    # Generates a Tempfile object similar to the object you'd get from the standard library CGI
    # module in a multipart request.
    #
    # Borrowed from action_controller/test_process.
    #
    class FakeUploadFile
      ##
      #
      # The filename, *not* including the path, of the ‘uploaded’ file
      #
      attr_reader :original_filename
      
      ##
      #
      # The content type of the ‘uploaded’ file
      #
      attr_reader :content_type
      
      ##
      #
      # Initializes a FakeUploadFile instance with the file that will be
      # ‘uploaded’.
      #
      # ==== Parameters
      #
      # [+path+]
      #   The path to the file that will be ‘uploaded’.
      # [+content_type+]
      #   The content type of the file that will be ‘uploaded’.
      #   Defaults to 'text/plain'.
      # [+binary+]
      #   Specifies whether or not the ‘uploaded’ file should be treated as a
      #   binary file.
      #
      # ==== Examples
      #
      #   f = FakeUploadFile.new('Rakefile')
      #   f # => #<FakeUploadFile @original_filename="Rakefile", @content_type="text/plain">
      #
      #   f = FakeUploadFile.new('rails.png', 'image/png')
      #   f # => #<FakeUploadFile @original_filename="rails.png", @content_type="image/jpg">
      #
      #   f = FakeUploadFile.new('docs.zip', 'application/zip', true)
      #   f # => #<FakeUploadFile @original_filename="docs.zip", @content_type="application/zip">
      #
      def initialize(path, content_type = Mime::TEXT, binary = false)
        path = path.to_s
        raise "#{path} file does not exist" unless File.exist?(path)
        @content_type = content_type
        @original_filename = path.sub(/^.*#{File::SEPARATOR}([^#{File::SEPARATOR}]+)$/) { $1 }
        @tempfile = Tempfile.new(@original_filename)
        @tempfile.binmode if binary
        FileUtils.copy_file(path, @tempfile.path)
      end
      
      def path #:nodoc:
        @tempfile.path
      end
      
      alias local_path path
      
      def method_missing(method_name, *args, &block) #:nodoc:
        @tempfile.send(method_name, *args, &block)
      end
    end
    
    ##
    #
    # Returns an instance of FakeUploadFile.
    #
    # ==== Parameters
    #
    # [+filename+]
    #   The path to the file that will be ‘uploaded’.
    # [+content_type+]
    #   The content type of the file that will be ‘uploaded’.
    #
    # ==== Examples
    #
    #   member.uploaded_file = uploaded_file('rails.png', 'image/png')
    #
    def uploaded_file(filename, content_type)
      FakeUploadFile.new(filename, content_type)
    end
    
    ##
    #
    # A convenience method which returns an instance of FakeUploadFile for the
    # Rails icon that’s included in the AttachmentSan lib.
    #
    def rails_icon
      uploaded_file(File.expand_path('../rails.png', __FILE__), 'image/png')
    end
  end
end

Test::Unit::TestCase.send(:include, AttachmentSan::UploadHelpers)