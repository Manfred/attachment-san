require File.expand_path('../helper', __FILE__)

describe "AttachmentProxy" do
  before do
    ActiveRecord::AttachmentSan::AttachmentProxy.class_eval { @convert_command = nil }
  end
  
  it "should find convert from ImageMagick on the system (fails when ImageMagick isn't installed)" do
    ActiveRecord::AttachmentSan::AttachmentProxy.convert_command.should.end_with('convert')
  end
end

describe "An AttachmentProxy" do
  before do
    @rails_icon = File.join(TEST_ROOT_DIR, 'fixtures/files/rails.png')
    ActiveRecord::AttachmentSan::AttachmentProxy.stubs(:webroot).returns(File.join(Dir.tmpdir, 'assets'))
    
    @attachment = Attachment.create :uploaded_data => rails_icon
    @proxy = @attachment.attachment
  end
  
  it "should use the path on the model as its path if it exists" do
    path = ['path', 'to', 'file']
    @attachment.expects(:respond_to?).with(:path).returns(true)
    @attachment.expects(:path).returns(path)
    @proxy.path.should == path
  end
  
  it "should use the filename for its path if it exists" do
    @attachment.expects(:respond_to?).with(:path).returns(false)
    @attachment.expects(:respond_to?).with(:filename).returns(true)
    @attachment.expects(:filename).returns('bunny.png')
    @proxy.path.should == ['attachments', 'bunny.png']
  end
  
  it "should use a default path otherwise" do
    @attachment.expects(:respond_to?).with(:path).returns(false)
    @attachment.expects(:respond_to?).with(:filename).returns(false)
    @proxy.path.should == ['attachments', @attachment.id]
  end
  
  it "should return a filename to where the attachment is on the filesystem" do
    @proxy.filename.should == File.join(ActiveRecord::AttachmentSan::AttachmentProxy.webroot, *@proxy.path)
  end
  
  it "should return a filename to the directory where the attachment is on the filesystem" do
    @proxy.filepath.should == File.join(ActiveRecord::AttachmentSan::AttachmentProxy.webroot, *(@proxy.path[0..-2]))
  end
  
  it "should return a path to where we can find the attachment on the web" do
    @proxy.urlpath.should == '/attachments/rails.png'
  end
  
  it "should save the file to the webroot" do
    @proxy.write_to_webroot
    File.should.exist(@proxy.filename)
  end
  
  it "should fit images within certain dimensions" do
    filename = File.join(@proxy.filepath, 'rails-80-80.png')
    @proxy.fit_within("8x8", filename)
    File.should.exist(filename)
    `file #{filename}`.should.include('6 x 8')
  end
  
  it "should issue the correct convert command when fitting images within dimensions" do
    filename = File.join(@proxy.filepath, 'rails-80-80.png')
    @command = ''; @proxy.stubs(:execute).with { |command| @command = command }
    @proxy.fit_within("8x8", filename)
    
    @command.should.include(filename)
    @command.should.include('-resize 8x8')
  end
end