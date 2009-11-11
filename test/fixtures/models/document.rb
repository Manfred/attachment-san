class Document < ActiveRecord::Base
  extend AttachmentSan::Has
  
  has_attachment  :watermark
  has_attachment  :logo, :variants => { :header => {} }
  
  has_attachments :misc_files
  has_attachments :images, :variants => {
    :thumbnail => {},
    :medium => {},
    :download => {}
  }
end