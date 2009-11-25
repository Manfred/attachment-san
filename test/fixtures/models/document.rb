class MyVariant < AttachmentSan::Variant
  def process!; end
end

class MyOtherVariant < AttachmentSan::Variant
  def process!; end
end

class MyProcessor
  def initialize(variant); end
end

class Document < ActiveRecord::Base
  has_attachment  :watermark
  has_attachment  :logo, :variants => { :header => MyVariant }
  
  has_attachments :misc_files, :filename_scheme => :keep_original, :process => proc { :from_process_proc }
  has_attachments :images, :variants => {
    :thumbnail => proc { |v| MyProcessor.new(v) },
    :medium_sized => proc {},
    :download => proc {}
  }
end

class OtherDocument < ActiveRecord::Base
  has_attachment  :logo, :variants => { :header => MyOtherVariant }
  has_attachments :misc_files, :filename_scheme => :keep_original, :process => proc { :from_other_process_proc }
end