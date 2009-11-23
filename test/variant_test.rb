require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan's variant class methods" do
  it "should return the variant class to use" do
    reflection = Document::Logo.reflect_on_variant(:header)
    reflection[:class].should.be MyVariant
  end
  
  it "should by default use the AttachmentSan::Variant class" do
    reflection = Document::Image.reflect_on_variant(:thumbnail)
    reflection[:class].should.be AttachmentSan::Variant
  end
  
  it "should not define a variant twice" do
    count_before = Document::Logo.variant_reflections.length
    Document.has_attachment :logo, :variants => { :header => MyVariant }
    Document::Logo.variant_reflections.length.should == count_before
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
  end
  
  it "should return the public_base_path specified in the attachment_san_options" do
    @thumbnail.public_base_path.should == Attachment.attachment_san_options[:public_base_path]
  end
  
  it "should return the extension of the original file" do
    Document::Image.attachment_san_options[:extension] = :keep_original
    @thumbnail.extension.should == 'png'
  end
  
  it "should use the extension specified in the attachment_san_options" do
    Document::Image.attachment_san_options[:extension] = :jpeg
    @thumbnail.extension.should == :jpeg
  end
  
  it "should create the directory that the file_path returns" do
    Document::Image.attachment_san_options[:filename_scheme] = :record_identifier
    
    @thumbnail.dir_path.should == File.dirname(@thumbnail.file_path)
    File.should.not.exist @thumbnail.dir_path
    @thumbnail.mkdir!
    File.should.exist @thumbnail.dir_path
  end
  
  it "should return a file_path without trailing dot if the original filename has no extension" do
    variant = @document.misc_files.build(
      :uploaded_file => uploaded_file(File.expand_path('../../Rakefile', __FILE__), 'text/plain')
    ).original
    
    variant.file_path.should == File.join(variant.base_path, 'Rakefile')
  end
  
  { :keep_original => 'png', :jpg => 'jpg' }.each do |setting, ext|
    it "should return a filename named after the variant name plus #{setting}" do
      Document::Image.attachment_san_options[:filename_scheme] = :variant_name
      Document::Image.attachment_san_options[:extension] = setting
      
      @thumbnail.filename.should == "thumbnail.#{ext}"
      @thumbnail.file_path.should == File.join(@thumbnail.base_path, "thumbnail.#{ext}")
      @thumbnail.public_path.should == File.join(@thumbnail.public_base_path, "thumbnail.#{ext}")
      
      @medium_sized.filename.should == "medium_sized.#{ext}"
      @medium_sized.file_path.should == File.join(@thumbnail.base_path, "medium_sized.#{ext}")
      @medium_sized.public_path.should == File.join(@thumbnail.public_base_path, "medium_sized.#{ext}")
    end
    
    it "should return the original filename and use extension #{setting}" do
      Document::Image.attachment_san_options[:filename_scheme] = :keep_original
      Document::Image.attachment_san_options[:extension] = setting
      
      @image.original.filename.should == "rails.png"
      @image.original.file_path.should == File.join(@thumbnail.base_path, "rails.png")
      @image.original.public_path.should == File.join(@thumbnail.public_base_path, "rails.png")
      
      @thumbnail.filename.should == "rails.thumbnail.#{ext}"
      @thumbnail.file_path.should == File.join(@thumbnail.base_path, "rails.thumbnail.#{ext}")
      @thumbnail.public_path.should == File.join(@thumbnail.public_base_path, "rails.thumbnail.#{ext}")
    end
    
    it "should return a filename which should be a random token from the record and append #{setting}" do
      Document::Image.attachment_san_options[:filename_scheme] = :token
      Document::Image.attachment_san_options[:extension] = setting
      @image.stubs(:token).returns('556d2e8e')
      
      @image.original.filename.should == "55/6d/2e/8e/rails.png"
      @image.original.file_path.should == File.join(@thumbnail.base_path, "55/6d/2e/8e/rails.png")
      @image.original.public_path.should == File.join(@thumbnail.public_base_path, "55/6d/2e/8e/rails.png")
      
      @thumbnail.filename.should == "55/6d/2e/8e/rails.thumbnail.#{ext}"
      @thumbnail.file_path.should == File.join(@thumbnail.base_path, "55/6d/2e/8e/rails.thumbnail.#{ext}")
      @thumbnail.public_path.should == File.join(@thumbnail.public_base_path, "55/6d/2e/8e/rails.thumbnail.#{ext}")
    end
    
    it "should return a filename which is based on the record identifier and variant name plus #{setting}" do
      Attachment.reset!
      
      Document::Image.attachment_san_options[:extension] = setting
      Document::Image.attachment_san_options[:filename_scheme] = :record_identifier
      @image.save!
      
      @thumbnail.filename.should == "/images/#{@image.id}/thumbnail.#{ext}"
      @thumbnail.file_path.should == File.join(@thumbnail.base_path, "/images/#{@image.id}/thumbnail.#{ext}")
      @thumbnail.public_path.should == File.join(@thumbnail.public_base_path, "/images/#{@image.id}/thumbnail.#{ext}")
      
      @medium_sized.filename.should == "/images/#{@image.id}/medium_sized.#{ext}"
      @medium_sized.file_path.should == File.join(@thumbnail.base_path, "/images/#{@image.id}/medium_sized.#{ext}")
      @medium_sized.public_path.should == File.join(@thumbnail.public_base_path, "/images/#{@image.id}/medium_sized.#{ext}")
    end
  end
end

describe "AttachmentSan::Variant, concerning a default variant without extra options" do
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

describe "AttachmentSan::Variant, concerning a default variant with extra options" do
  before do
    @upload = rails_icon
    @document = Document.new
    @variant = @document.misc_files.build(:uploaded_file => @upload).original
  end
  
  it "should return the filename_scheme value that was specified" do
    @variant.filename_scheme.should == :keep_original  end
  
  it "should return the original file's name" do
    @variant.filename.should == @variant.record.filename
  end
  
  it "should call the specified process proc" do
    result = @variant.process!
    result.should == :from_process_proc
  end
end