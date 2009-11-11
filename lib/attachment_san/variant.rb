module AttachmentSan
  module VariantClassMethods
    def self.extended(model)
      model.class_inheritable_accessor :variant_reflections
      model.variant_reflections = []
      model.define_variant :original, :klass => Variant::Original
    end
    
    def define_variant(label, options = {})
      label = label.to_sym
      variant_reflections << Variant::Reflection.new(label, options)
      
      # def original
      #   @original ||= AttachmentSan::Variant.new(self, :original)
      # end
      class_eval <<-DEF, __FILE__, __LINE__ + 1
        def #{label}
          @#{label} ||= self.class.reflect_on_variant(:#{label}).klass.new(self, :#{label})
        end
      DEF
    end
    
    def reflect_on_variant(label)
      variant_reflections.find { |r| r.label == label.to_sym }
    end
  end
  
  class Variant
    class Reflection
      attr_reader :label, :options
      def initialize(label, options)
        @label, @options = label, options
      end
      
      def class_name
        @options[:class_name]
      end
      
      def klass
        @options[:klass] ||= class_name.try(:constantize) || AttachmentSan::Variant
      end
    end
  end
  
  class Variant
    attr_reader :record, :label
    
    def initialize(record, label)
      @record, @label = record, label
    end
    
    def file_path
      File.join(@record.class.base_path, @record.filename)
    end
    
    def process!
    end
  end
  
  class Variant
    class Original < Variant
      def process!
        File.open(file_path, 'w') { |f| f.write @record.uploaded_file.read }
      end
    end
  end
end