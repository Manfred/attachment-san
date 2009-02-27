require 'active_record/attachment_san/mime_types'
require 'active_record/attachment_san/attachment_proxy'

module ActiveRecord # :nodoc:
  module AttachmentSan
    module ClassMethods
      # Using the attachment_san classmethod you add Attachment-San to an ActiveRecord model.
      #
      #   class Attachment < ActiveRecord::Base
      #     attachment_san
      #   end
      #
      # In it's most basic form it includes some instance methods and defines a few new
      # new callbacks. There are just two new instance methods defined on the model to make
      # sure they don't get in the way of your own methods: uploaded_data= and attachment.
      # Most of the functionality is accessed through the attachment proxy. The setter method
      # is used to get data into the the attachment proxy instance.
      #
      # Attachment-San creates two new callbacks on your record: before_upload and after_upload.
      # You can use then just like any other callbacks, they are call just before the uploaded
      # data is assigned to the attachment proxy and just after.
      def attachment_san(options={})
        unless included_modules.include?(InstanceMethods)
          include InstanceMethods
          define_callbacks :before_upload, :after_upload
          class_inheritable_accessor :attachment_san_options
          self.attachment_san_options = {}
        end
        self.attachment_san_options.merge!(options)
      end
    end
    
    module InstanceMethods
      # Checks the nature of the data and passes it on the the attachment proxy.
      def uploaded_data=(data)
        callback(:before_upload)
        return nil if data.nil? || data.size == 0 
        self.content_type = data.content_type.to_s if respond_to?(:content_type)
        self.filename = data.original_filename.to_s if respond_to?(:filename)
        if data.is_a?(StringIO)
          data.rewind
          attachment.uploaded_data = data
        else
          attachment.uploaded_file = data
        end
        callback(:after_upload)
        data
      end
      
      # Returns an attachment proxy instance for the record.
      def attachment
        @attachment ||= AttachmentProxy.new(self)
      end
    end
  end
end