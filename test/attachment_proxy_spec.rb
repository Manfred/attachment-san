require File.expand_path('../helper', __FILE__)

describe "AttachmentProxy" do
  before do
    @rails_icon = File.join(TEST_ROOT_DIR, 'fixtures/files/rails.png')
    ActiveRecord::AttachmentSan::AttachmentProxy.stubs(:webroot).returns(File.join(Dir.tmpdir, 'assets'))
    
    @attachment = Attachment.create :uploaded_data => rails_icon
    @proxy = @attachment.attachment
  end
  
  it "should save the file to the webroot" do
    @proxy.write_to_webroot
    File.should.exist(@proxy.filename)
  end
end