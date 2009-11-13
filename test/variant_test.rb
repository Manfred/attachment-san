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
  
  it "should return the `original' variant" do
    @image.original.should == @image.original
    @thumbnail.original.should == @image.original
  end
  
  it "should call the process proc" do
    MyProcessor.expects(:new).with(@thumbnail)
    @thumbnail.process!
  end
  
  it "should return the base_path specified in the attachment_san_options" do
    @thumbnail.base_path.should == Attachment.attachment_san_options[:base_path]
    
    @thumbnail.stubs(:base_path).returns('/another/path/yo')
    @thumbnail.base_path.should.not == Attachment.attachment_san_options[:base_path]
    @thumbnail.base_path.should == '/another/path/yo'
  end
  
  it "should return the extension of the original file" do
    Image.attachment_san_options[:extension] = :original_file
    @thumbnail.extension.should == 'png'
  end
  
  it "should use the extension specified in the attachment_san_options" do
    Image.attachment_san_options[:extension] = :jpeg
    @thumbnail.extension.should == 'jpeg'
  end
  
  it "should create the directory that the file_path returns" do
    Image.attachment_san_options[:filename_scheme] = :hashed
    
    @thumbnail.dir_path.should == File.dirname(@thumbnail.file_path)
    File.should.not.exist @thumbnail.dir_path
    @thumbnail.mkdir!
    File.should.exist @thumbnail.dir_path
  end
  
  { :original_file => 'png', :jpg => 'jpg' }.each do |setting, ext|
    it "should return a filename named after the variant name plus #{setting}" do
      Image.attachment_san_options[:filename_scheme] = :variant_name
      Image.attachment_san_options[:extension] = setting
      
      @thumbnail.filename.should == "thumbnail.#{ext}"
      @thumbnail.file_path.should == File.join(@thumbnail.base_path, "thumbnail.#{ext}")
      @medium_sized.filename.should == "medium_sized.#{ext}"
      @medium_sized.file_path.should == File.join(@thumbnail.base_path, "medium_sized.#{ext}")
    end
    
    it "should return a filename which is a hashed version of the variant name plus original filename and append #{setting}" do
      Image.attachment_san_options[:filename_scheme] = :hashed
      Image.attachment_san_options[:extension] = setting
      
      @thumbnail.filename.should == "55/6d/2e/8e/8b/5e/60/15/9d/3f/d9/a8/94/e3/08/26/e2/d6/fc/1c.#{ext}"
      @thumbnail.file_path.should == File.join(@thumbnail.base_path, "55/6d/2e/8e/8b/5e/60/15/9d/3f/d9/a8/94/e3/08/26/e2/d6/fc/1c.#{ext}")
      @medium_sized.filename.should == "d4/67/c8/41/c2/c9/23/0e/94/5b/0c/f1/21/86/52/cf/c5/a2/41/18.#{ext}"
      @medium_sized.file_path.should == File.join(@thumbnail.base_path, "d4/67/c8/41/c2/c9/23/0e/94/5b/0c/f1/21/86/52/cf/c5/a2/41/18.#{ext}")
    end
    
    it "should return a filename which is based on the record identifier and variant name plus #{setting}" do
      Attachment.reset!
      
      Image.attachment_san_options[:filename_scheme] = :record_identifier
      @image.save!
      
      Image.attachment_san_options[:extension] = setting
      @thumbnail.filename.should == "/images/#{@image.id}/thumbnail.#{ext}"
      @medium_sized.filename.should == "/images/#{@image.id}/medium_sized.#{ext}"
    end
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