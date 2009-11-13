require "digest"
require "fileutils"

module AttachmentSan
  class Variant
    module ClassMethods
      def self.extended(model)
        model.class_inheritable_accessor :variant_reflections
        model.variant_reflections = []
        model.define_variant :original, Variant::Original
      end
      
      def define_variant(name, variant_class_or_process_proc)
        name = name.to_sym
        variant_reflections << (reflection = { :name => name })
        
        case x = variant_class_or_process_proc
        when Class
          reflection[:class] = x
        when Proc
          reflection[:class] = Variant
          reflection[:process] = x
        else
          raise TypeError, "Please specify a variant class or process proc. Can't use `#{x.inspect}'."
        end
        
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
        case scheme = base_options[:filename_scheme]
        when :variant_name
          name.to_s
        when :record_identifier
          @record_class_name ||= @record.class.name.underscore.pluralize
          "/#{@record_class_name}/#{@record.to_param}/#{name}"
        when :hashed
          Digest::SHA1.hexdigest("#{name}+#{@record.filename}").scan(/.{2}/).join('/')
        else
          raise ArgumentError,
            "The :filename_scheme option should be one of `:hashed', `:record_identifier', or `:variant_name', it currently is `#{scheme.inspect}'."
        end << ".#{extension}"
    end
    
    def file_path
      File.join(base_path, filename)
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
        mkdir!
        File.open(file_path, 'w') { |f| f.write @record.uploaded_file.read }
      end
    end
  end
end