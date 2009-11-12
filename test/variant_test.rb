require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan::VariantReflection" do
  it "should return the variant class to use" do
    reflection = Logo.reflect_on_variant(:header)
    reflection[:class].should.be MyVariant
  end
  
  it "should by default use the AttachmentSan::Variant class" do
    reflection = Image.reflect_on_variant(:thumbnail)
    reflection[:class].should.be AttachmentSan::Variant
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
  
  it "should return the record it is a variant of" do
    @document.watermark.original.record.should == @document.watermark
  end
  
  it "should simply return the attachment model's base_path and original filename as the file_path " do
    @document.watermark.original.file_path.should == File.join(TMP_DIR, 'rails.png')
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

describe "A AttachmentSan::Variant instance" do
  before do
    @upload = rails_icon
    @document = Document.new
    @document.images.build :uploaded_file => @upload
  end
  
  it "should call the :process option proc" do
    variant = @document.images.first.thumbnail
    MyProcessor.expects(:new).with(variant)
    variant.process!
  end
end