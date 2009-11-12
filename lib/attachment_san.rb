require "attachment_san/has"
require "attachment_san/variant"

module AttachmentSan
  module Initializer
    def attachment_san(options = {})
      include AttachmentSan
      
      self.attachment_san_options = {
        :base_path       => Rails.root + 'public/images',
        :extension       => :original_file,
        :filename_scheme => :variant_name
      }.merge(options)
    end
  end
  
  mattr_accessor :attachment_class
  
  def self.included(model)
    self.attachment_class = model
    model.extend VariantModelClassMethods
    
    model.class_inheritable_accessor :attachment_san_options
    model.define_callbacks :before_upload, :after_upload
    model.after_save :process_variants!
  end
  
  attr_reader :uploaded_file
  
  def uploaded_file=(uploaded_file)
    callback :before_upload
    
    @uploaded_file    = uploaded_file
    self.filename     = uploaded_file.original_filename
    self.content_type = uploaded_file.content_type
    
    callback :after_upload
  end
  
  def extension
    filename.split('.').last
  end
  
  def variants
    self.class.variant_reflections.map { |reflection| send(reflection[:name]) }
  end
  
  def process_variants!
    variants.each(&:process!)
  end
end