module AttachmentSan
  ##
  #
  # This is the module that provides the class methods to define attachment
  # associations and variants.
  #
  # Options _not_ recognized by AttachmentSan are passed on to the association
  # macro. Which is either +has_one+ or +has_many+, depending on whether
  # +has_attachment+ or +has_attachments+ is being used.
  #
  # If you feel that the way AttachmentSan defines the association is *not*
  # according to your needs, then simply define it yourself _before_ the actual
  # attachment definition. AttachmentSan will then pick that up instead.
  #
  # Since the two attachment definition macros take the same parameters, the
  # definition of the parameters are given here instead of next to the method.
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
  #   The file path to the public document root to the root where the
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
  #       :full => proc { |variant|
  #         Miso::Image.fit(variant.original.file_path, variant.file_path, 1024, 768)
  #       },
  #       :inline => proc { |variant|
  #         Miso::Image.crop(variant.original.file_path, variant.file_path, 400, 400)
  #       }
  #     }
  #
  #     has_attachments :documents
  #   end
  #
  # The generated associations are regular ActiveRecord associations:
  #
  #   member.photo # => #<Member::Photo id: 1913, member_id: 213, … >
  #   member.documents # => [#<Member::Document id: 453, member_id: 213, … >, …]
  #
  # But in addition, the associated objects provide access to their variants:
  #
  #   member.photo.original
  #   member.photo.full
  #   member.photo.inline
  #
  # The ‘documents’ collection does *not* have any variants defined. Thus, the
  # only available available variant is the ‘original’:
  #
  #   member.documents.first.original
  #
  module Has
    MODEL_OPTIONS   = [:base_path, :public_base_path, :extension, :filename_scheme] #:nodoc:
    VARIANT_OPTIONS = [:name, :process, :class, :variants, :filename_scheme] #:nodoc:
    
    ##
    #
    # Defines a +has_one+ association, creates an attachment subclass nested
    # under this class, and defines the variants.
    #
    # Variant options are stored in the reflection hash, all other options are
    # passed on to the +has_one+ declaration.
    #
    # See AttachmentSan::Has for the parameters and examples.
    #
    def has_attachment(name, options = {})
      define_attachment_association :has_one, name, options
    end
    
    ##
    #
    # Defines a +has_many+ association, creates an attachment subclass nested
    # under this class, and defines the variants.
    #
    # Variant options are stored in the reflection hash, all other options are
    # passed on to the +has_many+ declaration.
    #
    # See AttachmentSan::Has for the parameters and examples.
    #
    def has_attachments(name, options = {})
      define_attachment_association :has_many, name, options
    end
    
    private
    
    def define_attachment_association(macro, name, options) #:nodoc:
      model_options = extract_options!(options, MODEL_OPTIONS)
      model = create_model(name, model_options)
      
      variant_options = extract_options!(options, VARIANT_OPTIONS)
      define_variants(model, variant_options)
      
      send(macro, name, options.merge(:class_name => model.name)) unless reflect_on_association(name)
    end
    
    def extract_options!(options, keys) #:nodoc:
      options.symbolize_keys!
      extracted_options = options.slice(*keys)
      options.except!(*keys)
      extracted_options
    end
    
    def define_variants(model, options) #:nodoc:
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
    
    def create_model(name, options) #:nodoc:
      name = name.to_s.classify
      modulized_mod_get(name)
    rescue NameError
      model = const_set(name, Class.new(AttachmentSan.attachment_class))
      model.attachment_san_options = AttachmentSan.attachment_class.attachment_san_options.merge(options)
      model
    end
  end
end