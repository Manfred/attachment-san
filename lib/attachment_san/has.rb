module AttachmentSan
  ##
  #
  # = AttachmentSan::Has
  #
  # This is the module that provides the class methods to define the attachment
  # associations and variants.
  #
  # Any options _not_ recognized by AttachmentSan are passed on to the
  # association macro. Either +has_one+ or +has_many+ depending on whether
  # +has_attachment+ or +has_attachments+ is being used.
  #
  # If you feel that the way AttachmentSan defines the assocaition isn’t what
  # you need, then define it yourself _before_ defining the attachment.
  # AttachmentSan will then simply use the existing assocaition.
  #
  # HIER WAS IK!
  #
  module Has
    MODEL_OPTIONS   = [:base_path, :public_base_path, :extension, :filename_scheme]
    VARIANT_OPTIONS = [:name, :process, :class, :variants, :filename_scheme]
    
    ##
    #
    # Defines a +has_one+ association, creates an attachment subclass nested
    # under this class, and defines the variants.
    #
    # Valid variant options are stored as the variant reflection, all others
    # are passed on to +has_one+.
    #
    # ==== Parameter and option parameters
    #
    # [+name+]
    #   The name to use for the association.
    # [+:variants+]
    #   A Hash of ‘variant name’-‘options’ pairs. See Variant for more
    #   information.
    # [+:base_path+]
    #   The file path to the public document root where the attachment files
    #   are to be stored.
    # [+:public_base_path+]
    #   The file path to from the public document root to the root where the
    #   attachment files are to be stored.
    # [+:extension+]
    #   The scheme to use for the attachment variant extension. See
    #   Variant#extension for more information.
    # [+:filename_scheme+]
    #   The scheme to use for the attachment variant filename. See
    #   Variant#filename for more information.
    #
    # ==== Examples
    #
    #   class Member < ActiveRecord::Base
    #     has_attachment :photo, :variants => {
    #       :full => proc { |variant| Miso::Image.fit(variant.original.file_path, variant.file_path, 1024, 768) },
    #       :inline => proc { |variant| Miso::Image.crop(variant.original.file_path, variant.file_path, 400, 400) }
    #     }
    #   end
    #
    # The generated association is like any other regular ActiveRecord association:
    #
    #   member.photo # => #<Member::Photo id: 1913, member_id: 213, … >
    #
    # But in addition, it provides access to the variants:
    #
    #   member.photo.original
    #   member.photo.full
    #   member.photo.inline
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