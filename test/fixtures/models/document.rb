class MyVariant < AttachmentSan::Variant; end

class Document < ActiveRecord::Base
  extend AttachmentSan::Has
  
  has_attachment  :watermark
  has_attachment  :logo, :variants => {
    :header => { :class_name => 'MyVariant' }
  }
  
  has_attachments :misc_files
  has_attachments :images, :variants => {
    :thumbnail => {},
    :medium => {},
    :download => {}
  }
end