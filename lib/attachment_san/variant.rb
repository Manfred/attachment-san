require "digest"
require "fileutils"

module AttachmentSan
  class Variant
    module ClassMethods
      def self.extended(model)
        model.class_inheritable_accessor :variant_reflections
        model.variant_reflections = []
      end
      
      def define_variant(name, options_or_class_or_proc)
        reflection =
          case x = options_or_class_or_proc
          when Hash
            { :class => Variant }.merge(x.symbolize_keys)
          when Class
            { :class => x }
          when Proc
            { :class => Variant, :process => x }
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
      
      def reflect_on_variant(name)
        variant_reflections.find { |r| r[:name] == name.to_sym }
      end
    end
  end
  
  class Variant
    attr_reader :record, :reflection
    
    def initialize(record, reflection)
      @record, @reflection = record, reflection
    end
    
    def base_options
      @record.class.attachment_san_options
    end
    
    def base_path
      base_options[:base_path]
    end
    
    def public_base_path
      base_options[:public_base_path]
    end
    
    def filename_scheme
      @reflection[:filename_scheme] || base_options[:filename_scheme]
    end
    
    def original
      @record.original
    end
    
    def name
      @reflection[:name]
    end
    
    def extension
      case ext = base_options[:extension]
      when :original_file
        @record.extension
      else
        ext.to_s
      end
    end
    
    def filename
      @filename ||=
        case filename_scheme
        when :variant_name
          name.to_s
        when :original_file
          @record.filename
        when :record_identifier
          @record_class_name ||= @record.class.name.underscore.pluralize
          "/#{@record_class_name}/#{@record.to_param}/#{name}"
        when :hashed
          Digest::SHA1.hexdigest("#{name}+#{@record.filename}").scan(/.{2}/).join('/')
        else
          raise ArgumentError, "The :filename_scheme option should be one of `:hashed', `:filename_scheme', `:record_identifier', or `:variant_name', it currently is `#{filename_scheme.inspect}'."
        end << ".#{extension}"
    end
    
    def file_path
      File.join(base_path, filename)
    end
    
    def public_path
      File.join(public_base_path, filename)
    end
    
    def dir_path
      File.dirname(file_path)
    end
    
    def mkdir!
      FileUtils.mkdir_p(dir_path)
    end
    
    def process!
      mkdir!
      @reflection[:process].call(self)
    end
    
    class Original < Variant
      def original
        self
      end
      
      def process!
        return super if @reflection[:process]
        mkdir!
        File.open(file_path, 'w') { |f| f.write @record.uploaded_file.read }
      end
    end
  end
end