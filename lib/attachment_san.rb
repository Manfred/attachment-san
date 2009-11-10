require "attachment_san/has"
require "attachment_san/variant"

module AttachmentSan
  def self.included(model)
    model.define_callbacks :before_upload, :after_upload
  end
  
  attr_reader :uploaded_file
  
  def uploaded_file=(uploaded_file)
    callback :before_upload
    @uploaded_file = uploaded_file
    callback :after_upload
  end
end