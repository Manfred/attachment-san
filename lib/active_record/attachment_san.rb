module ActiveRecord :nodoc
  module AttachmentSan

    module ClassMethods
      def has_attachment_accessors(options={})
      end
      alias_method :attachment_okudasai, :has_attachment_accessors
    end

    module InstanceMethods

      def uploaded_data=(data)
        return nil if data.nil? || data.size == 0 
        self.content_type = data.content_type if respond_to?(:content_type)
        self.filename = data.original_filename if respond_to?(:filename)
        if data.is_a?(StringIO)
          data.rewind
          self.temp_data = data.read
        else
          self.temp_path = data.path
        end
      end

      def temp_data=(data)
        temp_file = Tempfile.new(filename)
        temp_file.binmode
        temp_file.write data
        temp_file.close
      end
    end
  end
end