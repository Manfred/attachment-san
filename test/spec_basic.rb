require File.expand_path('../helper', __FILE__)

describe "A record infused with Attachment-San" do
  before do
    @rails_icon = File.join(TEST_ROOT_DIR, 'fixtures/files/rails.png')
    ActiveRecord::AttachmentSan::AttachmentProxy.stubs(:webroot).returns(File.join(Dir.tmpdir, 'assets'))
  end
  
  it "should handle files coming from CGI when instanciated" do
    attachment = Attachment.new :uploaded_data => rails_icon
    File.exist?(attachment.attachment.uploaded_file.path).should == true
  end
  
  it "should handle data coming from CGI when instanciated" do
    data = StringIO.new
    data.instance_eval do
      def content_type; 'image/png'; end
      def original_filename; 'rails.png'; end
    end
    data << File.read(@rails_icon)
    attachment = Attachment.new :uploaded_data => data
    File.exist?(attachment.attachment.uploaded_file.path).should == true
  end
  
  it "should return an attachment proxy" do
    attachment = Attachment.new :uploaded_data => rails_icon
    attachment.attachment.should.be.kind_of(ActiveRecord::AttachmentSan::AttachmentProxy)
  end
  
  it "should run before_upload before handling the uploaded file data" do
    attachment = Attachment.new
    attachment.expects(:prepare_uploaded_file).raises(Exception.new)
    begin
      attachment.uploaded_data = rails_icon
    rescue Exception
    end
    attachment.content_type.should.be.blank
    attachment.filename.should.be.blank
    attachment.attachment.uploaded_file.should.be.blank
  end
  
  it "should run after_upload after handling the uploaded file data" do
    attachment = Attachment.new
    attachment.expects(:process_uploaded_file).raises(Exception.new)
    begin
      attachment.uploaded_data = rails_icon
    rescue Exception
    end
    attachment.content_type.should.not.be.blank
    attachment.filename.should.not.be.blank
    attachment.attachment.uploaded_file.should.not.be.blank
  end
end