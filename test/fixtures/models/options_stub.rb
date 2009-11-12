class OptionsStub
  def self.new_subclass(&block)
    model = Class.new(self)
    model.instance_eval(&block)
    model
  end
  
  def self.include(mod)
    # no we don't!
  end
  
  class_inheritable_accessor :attachment_san_options
  extend AttachmentSan::Initializer
end