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
      
      original = { :class => Variant::Original }
      original.merge!(options) unless options.has_key?(:variants)
      model.send(:define_variant, :original, original)
      
      if variants = options[:variants]
        variants.each do |name, options|
          model.send(:define_variant, name, options)
        end
      end
    end
    
    # TODO: Currently creates these classes in the top level namespace
    def create_model(name)
      name = name.to_s.classify
      ::Object.const_get(name)
    rescue NameError
      ::Object.const_set name, Class.new(AttachmentSan.attachment_class)
    end
  end
end