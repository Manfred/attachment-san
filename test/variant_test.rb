require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan's variant reflection" do
  it "should return the variant class to use" do
    reflection = Logo.reflect_on_variant(:header)
    reflection[:class].should.be MyVariant
  end
  
  it "should by default use the AttachmentSan::Variant class" do
    reflection = Image.reflect_on_variant(:thumbnail)
    reflection[:class].should.be AttachmentSan::Variant
  end
end

describe "A AttachmentSan::Variant instance in general" do
  before do
    @upload = rails_icon
    @document = Document.new
    
    @image = @document.images.build(:uploaded_file => @upload)
    @thumbnail = @image.thumbnail
    @medium_sized = @image.medium_sized
  end
  
  it "should return the record it is a variant of" do
    @image.original.record.should == @image
  end
  
  it "should call the process proc" do
    MyProcessor.expects(:new).with(@thumbnail)
    @thumbnail.process!
  end
  
  it "should return the record's class base_path" do
    @thumbnail.base_path.should == AttachmentSan.attachment_class.base_path
    
    @thumbnail.stubs(:base_path).returns('/another/path/yo')
    @thumbnail.base_path.should.not == AttachmentSan.attachment_class.base_path
    @thumbnail.base_path.should == '/another/path/yo'
  end
  
  it "should return a filename named after the variant name" do
    Image.attachment_san_options[:filename_scheme] = :variant_name
    @thumbnail.filename.should == 'thumbnail'
    @medium_sized.filename.should == 'medium_sized'
  end
  
  it "should return a filename which is a hashed version of the variant name plus original filename" do
    Image.attachment_san_options[:filename_scheme] = :hashed
    @thumbnail.filename.should == '55/6d/2e/8e8b5e60159d3fd9a894e30826e2d6fc1c'
    @medium_sized.filename.should == 'd4/67/c8/41c2c9230e945b0cf1218652cfc5a24118'
  end
end

describe "AttachmentSan::Variant, concerning a default variant" do
  before do
    @upload = rails_icon
    @document = Document.new
    @document.build_watermark :uploaded_file => @upload
  end
  
  it "should use a custom variant for an `original'" do
    @document.watermark.original.should.be.instance_of AttachmentSan::Variant::Original
  end
  
  it "should simply copy the file to the file_path" do
    Attachment.reset!
    
    file_path = @document.watermark.original.file_path
    File.should.not.exist file_path
    @document.save!
    
    File.should.exist file_path
    File.read(file_path).should == File.read(@upload.path)
  end
end