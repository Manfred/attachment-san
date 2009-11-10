require 'tempfile'
require 'fileutils'

module AttachmentSan
  module UploadHelpers
    # Generates a Tempfile object similar to the object you'd get from the standard library CGI
    # module in a multipart request.
    #
    # Borrowed from action_controller/test_process.
    class FakeUploadFile
      # The filename, *not* including the path, of the "uploaded" file
      attr_reader :original_filename
      
      # The content type of the "uploaded" file
      attr_reader :content_type
      
      def initialize(path, content_type = Mime::TEXT, binary = false)
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
    
    def uploaded_file(filename, content_type)
      FakeUploadFile.new(filename, content_type)
    end
    
    def rails_icon
      uploaded_file(File.join(TEST_ROOT_DIR, 'fixtures', 'files', 'rails.png'), 'image/png')
    end
  end
end

Test::Spec::TestCase::InstanceMethods.send(:include, AttachmentSan::UploadHelpers)