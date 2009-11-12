class Attachment < ActiveRecord::Base
  attachment_san :base_path => TMP_DIR
  
  # Test code
  
  def self.reset!
    FileUtils.rm_rf TMP_DIR
    FileUtils.mkdir_p TMP_DIR
  end
  
  # User code
  
  belongs_to :attachable, :polymorphic => true
  
  attr_accessor :file_before_upload
  before_upload { |record| record.file_before_upload = record.uploaded_file }
  
  attr_accessor :file_after_upload
  after_upload  { |record| record.file_after_upload  = record.uploaded_file }
end