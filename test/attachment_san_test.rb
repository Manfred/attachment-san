require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan, concerning base options" do
  default = OptionsStub.new_subclass do
    attachment_san
  end
  
  specified = OptionsStub.new_subclass do
    attachment_san :base_path => '/some/base/path', :extension => :png, :filename_scheme => :hashed
  end
  
  it "should default the base_path to public/images" do
    default.attachment_san_options[:base_path].should == Rails.root + 'public/images'
  end
  
  it "should use the specified base_path" do
    specified.attachment_san_options[:base_path].should == '/some/base/path'
  end
  
  it "should default to use the variant's name as the filename for variants" do
    default.attachment_san_options[:filename_scheme].should == :variant_name
  end
  
  it "should use the specified file extension for variants" do
    specified.attachment_san_options[:filename_scheme].should == :hashed
  end
  
  it "should default to use the original file's extension for variants" do
    default.attachment_san_options[:extension].should == :original_file
  end
  
  it "should use the specified file extension for variants" do
    specified.attachment_san_options[:extension].should == :png
  end
end

describe "AttachmentSan, class methods" do
  before do
    @upload = rails_icon
    @attachment = Attachment.new(:uploaded_file => @upload)
  end
  
  it "should assign the base attachment class when attachment_san is called" do
    AttachmentSan.attachment_class.should.be Attachment
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
    Logo.variant_reflections.map { |r| r[:name] }.should == [:original, :header]
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
  
  it "should return the original file's extension" do
    @attachment.extension.should == 'png'
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
    @document.watermark.variants.map(&:name).should == [:original]
    @document.logo.variants.map(&:name).should == [:original, :header]
  end
end