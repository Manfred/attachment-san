module AttachmentSan
  module Has
    VALID_OPTIONS = [:name, :process, :class, :variants, :filename_scheme]
    
    def has_attachment(name, options = {})
      define_attachment_association :has_one, name, options
    end
    
    def has_attachments(name, options = {})
      define_attachment_association :has_many, name, options
    end
    
    private
    
    def define_attachment_association(macro, name, options)
      define_variants(name, extract_variant_options!(options))
      send(macro, name, options) unless reflect_on_association(name)
    end
    
    def extract_variant_options!(options)
      options.symbolize_keys!
      variant_options = options.slice(*VALID_OPTIONS)
      options.except!(*VALID_OPTIONS)
      variant_options
    end
    
    def define_variants(name, options)
      model = create_model(name)
      
      if options.has_key?(:variants)
        original = options[:variants][:original] || {}
        original[:class] ||= Variant::Original if original.is_a?(Hash)
        model.send(:define_variant, :original, original)
        
        if variants = options[:variants]
          variants.each do |name, variant_options|
            model.send(:define_variant, name, variant_options)
          end
        end
      else
        original = options
        original[:class] ||= Variant::Original if original.is_a?(Hash)
        model.send(:define_variant, :original, original)
      end
    end
    
    # TODO: Currently creates these classes in the top level namespace
    def create_model(name)
      name = name.to_s.classify
      const_get(name)
    rescue NameError
      const_set name, Class.new(AttachmentSan.attachment_class)
    end
  end
end