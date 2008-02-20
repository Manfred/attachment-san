require 'active_record/attachment_san/mime_types'

module ActiveRecord :nodoc
  module AttachmentSan
    module ClassMethods
      def attachment_san(options={})
        unless included_modules.include?(InstanceMethods)
          include InstanceMethods
        end
      end
    end

    module InstanceMethods
      def uploaded_data=(data)
        return nil if data.nil? || data.size == 0 
        self.content_type = data.content_type if respond_to?(:content_type)
        self.filename = data.original_filename if respond_to?(:filename)
        if data.is_a?(StringIO)
          data.rewind
          attachment.uploaded_data = data
        else
          attachment.uploaded_file = data
        end
      end

      def attachment
        @attachment ||= AttachmentProxy.new(self)
      end
    end

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
    end
  end
end