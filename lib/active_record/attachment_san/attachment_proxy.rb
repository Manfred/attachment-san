require 'uri'
require 'open3'
require 'fileutils'

module ActiveRecord :nodoc
  module AttachmentSan :nodoc
    class AttachmentProcessingError < StandardError; end
    
    class AttachmentProxy
      attr_accessor :model, :uploaded_file
      
      def initialize(model)
        @model = model
      end
      
      def uploaded_data=(data)
        unless data.nil?
          self.uploaded_file = Tempfile.new(model.filename)
          self.uploaded_file.binmode
          self.uploaded_file.write data
        end
      end
      
      def path
        if model.respond_to?(:path)
          model.path
        elsif model.respond_to?(:filename)
          ['attachments', model.filename]
        else
          ['attachments', model.id]
        end
      end
      
      def filename
        File.join(self.class.webroot, *path)
      end
      
      def filepath
        File.join(self.class.webroot, *path[0..-2])
      end
      
      def urlpath
        "/#{path.join('/')}"
      end
      
      def write_to_webroot
        FileUtils.mkdir_p(filepath)
        FileUtils.cp(uploaded_file.path, filename)
        FileUtils.chmod(0644, filename)
      end
      
      def fit_within(dimensions, output_path)
        convert([[:resize, dimensions]], output_path)
      end
      
      def convert(operations, output_path)
        FileUtils.mkdir_p(File.dirname(output_path))
        execute "#{self.class.image_magic_path}/convert '#{uploaded_file.path}' #{ operations.map { |op, arg| "-#{op} #{arg}" }.join(' ') } '#{output_path}'"
      end
      
      def execute(command)
        stdin, stdout, stderr = Open3.popen3(command)
        output = stdout.gets(nil)
        if output.nil? && (error_message = stderr.gets)
          if error_message =~ /:in\s`exec':\s(.+)\s\(.+\)$/
            error_message = $1
          end
          raise AttachmentProcessingError, "Command: \"#{command}\"\nOutput: \"#{error_message.chomp}\""
        end
        output
      end
      
      def self.image_magic_path
        '/opt/local/bin'
      end
      
      def self.webroot
        File.join(RAILS_ROOT, 'public')
      end
    end
  end
end