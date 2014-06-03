class MyVariant < AttachmentSan::Variant
  def process!; end
end

class MyOtherVariant < AttachmentSan::Variant
  def process!; end
end

class MyOriginal < AttachmentSan::Variant::Original
end

class MyProcessor
  def initialize(variant); end
end

class Document < ActiveRecord::Base
  has_attachment  :watermark, :as => :attachable
  has_attachment  :logo, :as => :attachable, :variants => { :header => MyVariant }
  
  has_attachments :misc_files, :as => :attachable, :class => MyOriginal, :filename_scheme => :keep_original, :process => proc { :from_process_proc }
  has_attachments :images, :as => :attachable, :variants => {
    :thumbnail => proc { |v| MyProcessor.new(v) },
    :medium_sized => proc {},
    :download => proc {}
  }
end

class OtherDocument < ActiveRecord::Base
  has_attachment  :logo, :as => :attachable, :variants => { :header => MyOtherVariant }
  has_attachments :misc_files, :as => :attachable, :filename_scheme => :keep_original, :process => proc { :from_other_process_proc }
  
  has_attachments :images, :as => :attachable, :base_path => File.join(TMP_DIR, '/other/base'), :public_base_path => '/other/public', :variants => {
    :normal => { :base_path => File.join(TMP_DIR, 'yet/another/base'), :process => proc {} }
  }
end