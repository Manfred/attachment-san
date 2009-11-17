module AttachmentSan
  module Has
    def has_attachment(name, options = {})
      define_variants(name, options)
      has_one name
    end
    
    def has_attachments(name, options = {})
      define_variants(name, options)
      has_many name
    end
    
    private
    
    def define_variants(name, options)
      model = create_model(name)
      
      original = { :class => Variant::Original }
      original.merge!(options) unless options.has_key?(:variants)
      model.define_variant(:original, original)
      
      if variants = options[:variants]
        variants.each do |name, options|
          model.define_variant(name, options)
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