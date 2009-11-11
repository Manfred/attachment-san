require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan::Variant, concerning a default variant" do
  before do
    Attachment.reset!
    
    @upload = rails_icon
    @document = Document.new
    @document.build_watermark :uploaded_file => @upload
  end
  
  it "should return the record it is a variant of" do
    @document.watermark.original.record.should == @document.watermark
  end
  
  it "should simply return the attachment model's base_path and original filename as the file_path " do
    @document.watermark.original.file_path.should == File.join(TMP_DIR, 'rails.png')
  end
  
  it "should simply copy the file to the file_path" do
    file_path = @document.watermark.original.file_path
    File.should.not.exist file_path
    @document.save!
    
    File.should.exist file_path
    File.read(file_path).should == File.read(@upload.path)
  end
end