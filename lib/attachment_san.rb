require "attachment_san/core_ext"
require "attachment_san/has"
require "attachment_san/variant"

module AttachmentSan
  module Initializer
    def attachment_san(options = {})
      include AttachmentSan
      
      opt = self.attachment_san_options = {
        :public_base_path => '',
        :extension        => :keep_original,
        :filename_scheme  => :variant_name
      }.merge(options)
      # Defaults :base_path to expanded :public_base_path.
      opt[:base_path] ||= Rails.root + File.join('public', opt[:public_base_path])
      opt
    end
  end
  
  mattr_accessor :attachment_class
  
  def self.included(model)
    self.attachment_class = model
    model.extend Variant::ClassMethods
    
    model.class_inheritable_accessor :attachment_san_options
    model.define_callbacks :before_upload, :after_upload
    model.after_create :process_variants!
  end
  
  attr_reader :uploaded_file
  
  def uploaded_file=(uploaded_file)
    callback :before_upload
    
    @uploaded_file    = uploaded_file
    self.filename     = uploaded_file.original_filename
    self.content_type = uploaded_file.content_type.strip
    
    callback :after_upload
  end
  
  def extension
    filename.split('.').last if filename.include?('.')
  end
  
  def filename_without_extension
    filename.include?('.') ? filename.split('.')[0..-2].join('.') : filename
  end
  
  def variants
    self.class.variant_reflections.map { |reflection| send(reflection[:name]) }
  end
  
  def process_variants!
    variants.each(&:process!)
  end
end