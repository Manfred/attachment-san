require "digest"
require "fileutils"

module AttachmentSan
  class Variant
    module ClassMethods
      def self.extended(model) #:nodoc:
        model.class_inheritable_accessor :variant_reflections
        model.variant_reflections = []
      end
      
      ##
      #
      # Returns the variant reflection hash for the given variant name.
      #
      # ==== Parameters
      #
      # [+name+]
      #   The name of the variant.
      #
      # ==== Examples
      #
      #   Member::Photo.reflect_on_variant(:inline) # => { :class => AttachmentSan::Variant, :name => :inline, :process => #<Proc:app/models/member.rb:20> }
      #   Member::Photo.reflect_on_variant(:non_existant) # => nil
      #
      def reflect_on_variant(name)
        variant_reflections.find { |r| r[:name] == name.to_sym }
      end
      
      private
      
      def define_variant(name, options_or_class_or_proc)
        return if reflect_on_variant(name)
        
        reflection =
          case x = options_or_class_or_proc
          when Hash
            { :class => Variant }.merge(x.symbolize_keys)
          when Class
            { :class => x }
          when Proc
            { :class => Variant, :process => x }
          when nil
            { :class => modulized_mod_get(name.to_s.camelize) }
          else
            raise TypeError, "Please specify a options hash, variant class, or process proc. Can't use `#{x.inspect}'."
          end
        
        reflection[:name] = name = name.to_sym
        variant_reflections << reflection
        
        # def original
        #   @original ||= begin
        #     reflection = self.class.reflect_on_variant(:original)
        #     reflection.klass.new(self, reflection)
        #   end
        # end
        class_eval <<-DEF, __FILE__, __LINE__ + 1
          def #{name}
            @#{name} ||= begin
              reflection = self.class.reflect_on_variant(:#{name})
              reflection[:class].new(self, reflection)
            end
          end
        DEF
      end
    end
  end
  
  class Variant
    attr_reader :record, :reflection
    
    ##
    #
    # Initializes a Variant for a given record. You don’t normally need to use
    # this directly. The instance will be returned by accessing the named
    # variant methods on the record instance.
    #
    # ==== Parameters
    #
    # [+record+]
    #   The record for which the variant will return the path info.
    # [+reflection+]
    #   The variant reflection hash on which the variant will base the path
    #   info.
    #
    def initialize(record, reflection)
      @record, @reflection = record, reflection
    end
    
    ##
    #
    # Returns the global options hash from the attachment model.
    #
    def base_options
      @record.class.attachment_san_options
    end
    
    ##
    #
    # Returns the file path to the public document root where the attachment
    # files are to be stored.
    #
    def base_path
      @reflection[:base_path] || base_options[:base_path]
    end
    
    ##
    #
    # Returns the file path to the public document root to the root where the
    # attachment files are to be stored.
    #
    def public_base_path
      @reflection[:public_base_path] || base_options[:public_base_path]
    end
    
    ##
    #
    # Returns the scheme to use when generating a filename for the attachment
    # file.
    #
    def filename_scheme
      @reflection[:filename_scheme] || base_options[:filename_scheme]
    end
    
    ##
    #
    # Returns the ‘original’ variant for the +record+. Use this to get the path
    # to the original file on disk.
    #
    # ==== Examples
    #
    # In the following example, the ‘original’ variant is given to an external
    # library which, in this case, reads the file and generates a new one in
    # the location that the ‘inline’ variant points to:
    #
    #   class Member < ActiveRecord::Base
    #     has_attachment :photo, :variants => {
    #       :inline => proc { |variant| Miso::Image.crop(variant.original.file_path, variant.file_path, 400, 400) }
    #     }
    #   end
    #
    def original
      @record.original
    end
    
    ##
    #
    # Returns the name of the variant.
    #
    def name
      @reflection[:name]
    end
    
    ##
    #
    # Returns the extension to be used for the filename.
    #
    # ==== Examples
    #
    #   class Member < ActiveRecord::Base
    #     has_attachment :photo, :extension => :keep_original, :variants => { :inline => proc { … } }
    #   end
    #
    #   member.photo.extension # => 'jpg'
    #   member.photo.inline.extension # => 'jpg'
    #
    #   class Member < ActiveRecord::Base
    #     has_attachment :photo, :extension => :png, :variants => { :inline => proc { … } }
    #   end
    #
    #   member.photo.extension # => 'jpg'
    #   member.photo.inline.extension # => 'png'
    #
    def extension
      (ext = base_options[:extension]) == :keep_original ? @record.extension : ext
    end
    
    ##
    #
    # Returns the record’s token to be used for the filename if the
    # +:filename_scheme+ is set to +:token+. This method will split the token
    # after every two characters. The filename method will then join these
    # parts with a slash.
    #
    # ==== Examples
    #
    #   member.token # => "g41b6c3f"
    #   member.photo.inline.token # => ["g4", "1b", "6c", "3f"]
    #
    def token
      @record.token.scan(/.{2}/)
    end
    
    ##
    #
    # Returns the original filename, without extension, and appends the
    # variant’s name.
    #
    # ==== Examples
    #
    #   member.photo.filename # => "image.jpg"
    #   member.photo.inline.filename_with_variant_name # => "image.inline"
    #
    def filename_with_variant_name
      "#{@record.filename_without_extension}.#{name}"
    end
    
    ##
    #
    # Returns the variant’s filename, based on the +:filename_scheme+ option.
    #
    # ==== Examples
    #
    # Consider a file with the name "image.jpg":
    #
    #   member.filename # => "image.jpg"
    #
    #   class Member < ActiveRecord::Base
    #     has_attachment :photo, :filename_scheme => :variant_name, :variants => { :inline => proc { … } }
    #   end
    #
    #   member.photo.inline.filename # => "inline.jpg"
    #
    #   class Member < ActiveRecord::Base
    #     has_attachment :photo, :filename_scheme => :keep_original, :variants => { :inline => proc { … } }
    #   end
    #
    #   member.photo.original.filename # => "image.jpg"
    #   member.photo.inline.filename # => "image.inline.jpg"
    #
    #   class Member < ActiveRecord::Base
    #     has_attachment :photo, :filename_scheme => :record_identifier, :variants => { :inline => proc { … } }
    #   end
    #
    #   member.photo.id # => 123
    #   member.photo.inline.filename # => "/photo/123/inline.jpg"
    #
    #   class Member < ActiveRecord::Base
    #     has_attachment :photo, :filename_scheme => :token, :variants => { :inline => proc { … } }
    #   end
    #
    #   member.token # => "g41b6c3f"
    #   member.photo.original.filename # => "/g4/1b/6c/3f/image.jpg"
    #   member.photo.inline.filename # => "/g4/1b/6c/3f/image.inline.jpg"
    #
    def filename
      unless @filename
        @filename = 
          case filename_scheme
          when :variant_name
            name.to_s
          when :keep_original
            filename_with_variant_name
          when :record_identifier
            # For now we take only the demodulized attachment class name.
            @record_class_name ||= @record.class.name.demodulize.underscore.pluralize
            "/#{@record_class_name}/#{@record.to_param}/#{name}"
          when :token
            File.join(token, filename_with_variant_name)
          else
            raise ArgumentError, "The :filename_scheme option should be one of `:token', `:filename_scheme', `:record_identifier', or `:variant_name', it currently is `#{filename_scheme.inspect}'."
          end
        @filename << ".#{extension}" unless extension.blank?
      end
      @filename
    end
    
    ##
    #
    # Returns the full file path to the attachment on disk. Created by joining
    # the base_path and filename.
    #
    def file_path
      File.join(base_path, filename)
    end
    
    ##
    #
    # Returns the file path from the public document root to the attachment.
    # Created by joining the public_base_path and filename.
    #
    # This is the path you’d communicate with the user.
    #
    # ==== Examples
    #
    #   image_tag(member.photo.inline.public_path)
    #
    def public_path
      File.join(public_base_path, filename)
    end
    
    ##
    #
    # Returns the full path to the directory on disk in which the attachment
    # is stored.
    #
    def dir_path
      File.dirname(file_path)
    end
    
    ##
    #
    # Creates the directory on disk where the attachment will be stored.
    #
    def mkdir!
      FileUtils.mkdir_p(dir_path)
    end
    
    ##
    #
    # Creates the directory returned by dir_path and calls the +process+ proc
    # in the variant’s reflection hash.
    #
    def process!
      mkdir!
      @reflection[:process].call(self)
    end
    
    ##
    #
    # = AttachmentSan::Variant::Original
    #
    # This is the class that’s used for the ‘original’ variants. It overrides
    # a few methods, since an ‘original’ should be treated slightly different.
    #
    class Original < Variant
      ##
      #
      # Returns +self+.
      #
      def original
        self
      end
      
      ##
      #
      # Returns the ‘original’ variant’s filename, which works different than
      # the implementation in AttachmentSan::Variant, when the chosen
      # +filename_scheme+ is either +:token+ or +:keep_original+.
      #
      # ==== Examples
      #
      # Consider a file with the name "image.jpg":
      #
      #   member.filename # => "image.jpg"
      #
      #   class Member < ActiveRecord::Base
      #     has_attachment :photo, :filename_scheme => :keep_original, :variants => { :inline => proc { … } }
      #   end
      #
      # Does not include the variant name:
      #
      #   member.photo.original.filename # => "image.jpg"
      #
      #   class Member < ActiveRecord::Base
      #     has_attachment :photo, :filename_scheme => :token, :variants => { :inline => proc { … } }
      #   end
      #
      # Does not include the variant name:
      #
      #   member.photo.original.filename # => "/g4/1b/6c/3f/image.jpg"
      #
      def filename
        @filename ||=
          case filename_scheme
          when :token
            File.join(token, @record.filename)
          when :keep_original
            @record.filename
          else
            super
          end
      end
      
      ##
      #
      # Unless a +:process+ proc was specified, this method will simply read
      # the uploaded file and write it to the location returned by file_path.
      #
      def process!
        return super if @reflection[:process]
        mkdir!
        File.open(file_path, 'w') { |f| f.write @record.uploaded_file.read }
      end
    end
  end
end