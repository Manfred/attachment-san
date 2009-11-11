module AttachmentSan
  class Variant
    attr_reader :record, :label
    
    def initialize(record, label)
      @record, @label = record, label
    end
    
    def file_path
      File.join(@record.class.base_path, @record.filename)
    end
    
    def process!
      File.open(file_path, 'w') { |f| f.write @record.uploaded_file.read }
    end
  end
end