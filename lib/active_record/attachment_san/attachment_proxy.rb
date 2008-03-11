module ActiveRecord :nodoc
  module AttachmentSan :nodoc
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
      
      def filename
        File.join(filepath, model.filename)
      end
      
      def filepath
        File.join(webroot, model.class.to_s.tableize)
      end
      
      def webroot
        File.join(RAILS_ROOT, 'public')
      end
      
      def finalize_uploaded_file
        FileUtils.mkdir_p(filepath)
        FileUtils.cp(uploaded_file.path, filename)
      end
      
      def self.after_save(record)
        record.attachment.finalize_uploaded_file
      end
    end
  end
end