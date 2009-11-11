module AttachmentSan
  class Replay
    def self.capture(method, arguments, block = nil)
      { :method => method, :arguments => arguments, :block => block }
    end
    
    (instance_methods - %w{ class instance_variable_get }).each { |meth| undef_method(meth) unless meth =~ /\A__/ }
    
    def initialize(object)
      @operations = []
      @object = object
    end
    
    def replay!(*extra_operations)
      object = @object
      
      if new = extra_operations.find { |o| o[:method] == :new }
        extra_operations.delete(new)
        object = __send_operation__(@object, new)
      end
      
      (@operations + extra_operations).each do |operation|
        __send_operation__(object, operation)
      end
    end
    
    def method_missing(method, *arguments, &block)
      @operations << self.class.capture(method, arguments, block)
      self
    end
    
    private
    
    def __send_operation__(object, operation)
      object.send operation[:method], *operation[:arguments], &operation[:block]
    end
  end
end

module Kernel
  def Replay(object)
    AttachmentSan::Replay.new(object)
  end
end