module AttachmentSan
  module Has
    def has_attachment(name, options = {})
      define_variants(name, options)
      has_one name, :as => :attachable
    end
    
    def has_attachments(name, options = {})
      define_variants(name, options)
      has_many name, :as => :attachable
    end
    
    private
    
    def define_variants(name, options)
      options[:variants] ||= {}
      model = create_model(name)
      
      options[:variants].each do |label, variant_options|
        model.define_variant(label, variant_options)
      end
    end
    
    def create_model(name, &block)
      ::Object.const_set name.to_s.classify, Class.new(Attachment, &block)
    end
  end
end