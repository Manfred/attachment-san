require File.expand_path('../test_helper', __FILE__)

class TakesAllKindsOfArgs
  class << self
    attr_accessor :arg1, :arg2, :block
    
    def foo(arg1, arg2, &block)
      @arg1, @arg2, @block = arg1, arg2, block
    end
  end
end

class ImageProcessor; end

describe "Replay" do
  before do
    @replayer = Replay(TakesAllKindsOfArgs)
    @replayer.foo(:arg1, :arg2) { :ok }
  end
  
  it "should store calls that are to be replayed" do
    operation = @replayer.instance_variable_get(:@operations).last
    
    operation[:method].should == :foo
    operation[:arguments][0] == :arg1
    operation[:arguments][1] == :arg2
    operation[:block].call.should == :ok
  end
  
  it "should be able to initialize an instance of a given class" do
    @replayer.replay!
    
    TakesAllKindsOfArgs.arg1.should == :arg1
    TakesAllKindsOfArgs.arg2.should == :arg2
    TakesAllKindsOfArgs.block.call.should == :ok
  end
  
  it "should replay the operations in the given order and initialize with an optional extra operation given to apply" do
    replayer = Replay(ImageProcessor).crop(123, 456).fit(123, 456).sharpen
    
    processor = mock('ImageProcessor')
    ImageProcessor.expects(:new).with('/some/input/image.jpg').returns(processor)
    processor.expects(:crop).with(123, 456)
    processor.expects(:fit).with(123, 456)
    processor.expects(:sharpen)
    processor.expects(:write).with('/some/output/image.jpg')
    
    replayer.replay!(
      AttachmentSan::Replay.capture(:new, ['/some/input/image.jpg']),
      AttachmentSan::Replay.capture(:write, ['/some/output/image.jpg'])
    )
  end
  
  it "should be a blank slate class so that it forwards all calls" do
    @replayer.object_id
    TakesAllKindsOfArgs.expects(:object_id)
    @replayer.replay!
  end
end