module AttachmentSan
  module Has
    MODEL_OPTIONS   = [:base_path, :public_base_path, :extension, :filename_scheme]
    VARIANT_OPTIONS = [:name, :process, :class, :variants, :filename_scheme]
    
    def has_attachment(name, options = {})
      define_attachment_association :has_one, name, options
    end
    
    def has_attachments(name, options = {})
      define_attachment_association :has_many, name, options
    end
    
    private
    
    def define_attachment_association(macro, name, options)
      model_options = extract_options!(options, MODEL_OPTIONS)
      model = create_model(name, model_options)
      
      variant_options = extract_options!(options, VARIANT_OPTIONS)
      define_variants(model, variant_options)
      
      send(macro, name, options.merge(:class_name => model.name)) unless reflect_on_association(name)
    end
    
    def extract_options!(options, keys)
      options.symbolize_keys!
      extracted_options = options.slice(*keys)
      options.except!(*keys)
      extracted_options
    end
    
    def define_variants(model, options)
      original = options[:variants] ? (options[:variants][:original] || {}) : options
      original[:class] ||= Variant::Original if original.is_a?(Hash)
      model.send(:define_variant, :original, original)
      
      if variants = options[:variants]
        variants.each do |name, variant_options|
          model.send(:define_variant, name, variant_options)
        end
      end
      
      model
    end
    
    def create_model(name, options)
      name = name.to_s.classify
      modulized_mod_get(name)
    rescue NameError
      model = const_set(name, Class.new(AttachmentSan.attachment_class))
      model.attachment_san_options.merge!(options)
      model
    end
  end
end