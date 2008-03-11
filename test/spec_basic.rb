require File.dirname(__FILE__) + '/helper'

describe "Attachment-San" do
  before do
    @rails_icon = File.join(TEST_ROOT_DIR, 'fixtures/files/rails.png')
    ActiveRecord::AttachmentSan::AttachmentProxy.any_instance.stubs(:webroot).returns(Dir.tmpdir)
  end
  
  it "should handle files coming from CGI when instanciated" do
    attachment = Attachment.new :uploaded_data => uploaded_file(@rails_icon, 'image/png')
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
  
  it "should save the file to the webroot on create" do
    attachment = Attachment.create :uploaded_data => uploaded_file(@rails_icon, 'image/png')
    File.exist?(attachment.attachment.filename).should == true
  end
end