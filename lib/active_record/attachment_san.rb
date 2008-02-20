module ActiveRecord :nodoc
  module AttachmentSan
    module ClassMethods
      def has_attachment_accessors(options={})
        unless included_modules.include?(InstanceMethods)
          include InstanceMethods
        end
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
          attachment.temp_data = data.read
        else
          attachment.temp_path = data.path
        end
      end

      def attachment
        @attachment ||= AttachmentProxy.new(self)
      end
    end

    class AttachmentProxy
      def initialize(model)
        @model = model
      end

      def temp_data=(data)
        unless data.nil?
          temp_file = Tempfile.new(filename)
          temp_file.binmode
          temp_file.write data
          temp_path = temp_file.path
        end
      end

      def temp_path=(path)
      end
    end
  end
end