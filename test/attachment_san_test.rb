require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan, class methods" do
  before do
    @upload = rails_icon
    @attachment = Attachment.new(:uploaded_file => @upload)
  end
  
  it "should assign the base_path for where to store the variants" do
    begin
      Attachment.base_path.should == TMP_DIR
      Attachment.base_path = '/some/base/path'
      Attachment.base_path.should == '/some/base/path'
    ensure
      Attachment.base_path = TMP_DIR
    end
  end
  
  it "should call a before_upload filter chain before actually assigning the new uploaded file" do
    new_upload = rails_icon
    @attachment.uploaded_file = new_upload
    @attachment.file_before_upload.should.be @upload
  end
  
  it "should call an after_upload filter chain after assigning the new uploaded file" do
    @attachment.file_after_upload.should.be @upload
  end
  
  it "should define a variant with options" do
    Logo.variant_reflections.map { |r| r[:label] }.should == [:original, :header]
    Logo.new.header.should.be.instance_of MyVariant
  end
end

describe "AttachmentSan, instance methods" do
  before do
    @upload = rails_icon
    @attachment = Attachment.new(:uploaded_file => @upload)
  end
  
  it "should make a model accept a file upload" do
    @attachment.uploaded_file.should.be @upload
  end
  
  it "should assign the original filename to the model" do
    @attachment.filename.should == @upload.original_filename
  end
  
  it "should assign the content type to the model" do
    @attachment.content_type.should == @upload.content_type
  end
end

describe "An AttachmentSan instance, concerning variants" do
  before do
    @upload = rails_icon
    @document = Document.new
    @document.build_logo :uploaded_file => @upload
    @document.build_watermark :uploaded_file => @upload
  end
  
  it "should call process on each of it's variants" do
    @document.watermark.original.expects(:process!)
    @document.logo.original.expects(:process!)
    @document.logo.header.expects(:process!)
    @document.save!
  end
  
  it "should return it's variants" do
    @document.watermark.variants.map(&:label).should == [:original]
    @document.logo.variants.map(&:label).should == [:original, :header]
  end
end