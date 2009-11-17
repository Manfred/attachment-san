class OptionsStub
  def self.new_subclass(&block)
    before = AttachmentSan.attachment_class
    model = Class.new(self)
    model.instance_eval(&block)
    AttachmentSan.attachment_class = before
    model
  end
  
  def self.define_callbacks(*args)
    # no we don't!
  end
  
  def self.after_create(m)
    # no we don't!
  end
  
  class_inheritable_accessor :attachment_san_options
  extend AttachmentSan::Initializer
end