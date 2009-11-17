require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan, concerning base options" do
  default = OptionsStub.new_subclass do
    attachment_san
  end
  
  default_with_public_path = OptionsStub.new_subclass do
    attachment_san :public_base_path => '/files/assets'
  end
  
  specified = OptionsStub.new_subclass do
    attachment_san :base_path => '/some/base/path', :public_base_path => '/files/assets', :extension => :png, :filename_scheme => :hashed
  end
  
  it "should default the base_path to `public'" do
    default.attachment_san_options[:base_path].should == Rails.root + 'public/'
  end
  
  it "should use the specified base_path" do
    specified.attachment_san_options[:base_path].should == '/some/base/path'
  end
  
  it "should default the public_base_path to an empty string" do
    default.attachment_san_options[:public_base_path].should == ''
  end
  
  it "should use the specified public_base_path" do
    specified.attachment_san_options[:public_base_path].should == '/files/assets'
  end
  
  it "should default the base_path to `public' + public_base_path" do
    default_with_public_path.attachment_san_options[:base_path].should == Rails.root + 'public/files/assets'
  end
  
  it "should default to use the variant's name as the filename for variants" do
    default.attachment_san_options[:filename_scheme].should == :variant_name
  end
  
  it "should use a hashed version for variant filenames" do
    specified.attachment_san_options[:filename_scheme].should == :hashed
  end
  
  it "should use the unique records identifier for variant filenames" do
    OptionsStub.new_subclass do
      attachment_san :filename_scheme => :record_identifier
    end.attachment_san_options[:filename_scheme].should == :record_identifier
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
    
    @attachment.stubs(:filename).returns('Rakefile')
    @attachment.extension.should.be nil
  end
end

describe "An AttachmentSan instance, concerning variants" do
  before do
    @upload = rails_icon
    @document = Document.new
    @document.build_logo :uploaded_file => @upload
    @document.build_watermark :uploaded_file => @upload
  end
  
  it "should call process on each of it's variants after create" do
    @document.watermark.original.expects(:process!)
    @document.logo.original.expects(:process!)
    @document.logo.header.expects(:process!)
    @document.save!
  end
  
  it "should not call process when the model already exists" do
    @document.save!
    
    @document.watermark.original.expects(:process!).never
    @document.logo.original.expects(:process!).never
    @document.logo.header.expects(:process!).never
    @document.save!
  end
  
  it "should return it's variants" do
    @document.watermark.variants.map(&:name).should == [:original]
    @document.logo.variants.map(&:name).should == [:original, :header]
  end
end