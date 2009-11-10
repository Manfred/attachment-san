# class Attachment < ActiveRecord::Base
#   attachment_san
#   before_upload :prepare_uploaded_file
#   after_upload :process_uploaded_file
#   
#   def prepare_uploaded_file
#   end
#   
#   def process_uploaded_file
#   end
# end

class Attachment < ActiveRecord::Base
  include AttachmentSan
  
  belongs_to :attachable, :polymorphic => true
end