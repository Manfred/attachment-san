module AttachmentSan
  module VariantModelClassMethods
    def self.extended(model)
      model.class_inheritable_accessor :variant_reflections
      model.variant_reflections = []
      model.define_variant :original, Variant::Original
    end
    
    def define_variant(label, variant_class_or_process_proc)
      label = label.to_sym
      variant_reflections << (reflection = { :label => label })
      
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
        def #{label}
          @#{label} ||= begin
            reflection = self.class.reflect_on_variant(:#{label})
            reflection[:class].new(self, reflection)
          end
        end
      DEF
    end
    
    def reflect_on_variant(label)
      variant_reflections.find { |r| r[:label] == label.to_sym }
    end
  end
  
  class Variant
    attr_reader :record, :reflection
    
    def initialize(record, reflection)
      @record, @reflection = record, reflection
    end
    
    def label
      @reflection[:label]
    end
    
    def file_path
      File.join(@record.class.base_path, @record.filename)
    end
    
    def process!
      @reflection[:process].call(self)
    end
    
    class Original < Variant
      def process!
        File.open(file_path, 'w') { |f| f.write @record.uploaded_file.read }
      end
    end
  end
end