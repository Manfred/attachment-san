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
      if variants = options[:variants]
        variants.each do |name, class_or_proc|
          model.define_variant(name, class_or_proc)
        end
      end
    end
    
    # TODO: Currently creates these classes in the top level namespace and
    # assumes the class does not exist yet.
    def create_model(name)
      ::Object.const_set name.to_s.classify, Class.new(AttachmentSan.attachment_class)
    end
  end
end