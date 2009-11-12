module AttachmentSan
  module VariantModelClassMethods
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
  
  class Variant
    attr_reader :record, :reflection
    
    def initialize(record, reflection)
      @record, @reflection = record, reflection
    end
    
    def name
      @reflection[:name]
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