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
        File.join(webroot, path, model.filename)
      end
      
      def path
        model.class.to_s.tableize
      end
      
      def webroot
        File.join(RAILS_ROOT, 'public')
      end
    end
  end
end