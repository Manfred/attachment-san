require "attachment_san/has"
require "attachment_san/variant"

module AttachmentSan
  module ClassMethods
    def define_variant(label)
      label = label.to_sym
      variant_labels << label
      
      # def original
      #   @original ||= AttachmentSan::Variant.new(self, :original)
      # end
      class_eval <<-DEF, __FILE__, __LINE__ + 1
        def #{label}
          @#{label} ||= AttachmentSan::Variant.new(self, :#{label})
        end
      DEF
    end
  end
  
  def self.included(model)
    model.extend ClassMethods
    
    model.class_inheritable_accessor :base_path, :variant_labels
    model.variant_labels = []
    model.define_variant :original
    
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
  
  def variants
    self.class.variant_labels.map { |label| send label }
  end
  
  def process_variants!
    variants.each(&:process!)
  end
end