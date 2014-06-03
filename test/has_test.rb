require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan::Has" do
  process_proc = proc {}
  
  it "should pass on any unknown options to the has_one macro" do
    Document.expects(:has_one).with(:other_file, :as => :attachable, :order => :updated_at, :class_name => 'Document::OtherFile')
    Document.expects(:define_variants).with do |model, options|
      model == Document::OtherFile && options == { :process => process_proc, :class => MyVariant }
    end
    
    Document.has_attachment :other_file, :as => :attachable, :order => :updated_at,
                                         :process => process_proc, :class => MyVariant, :filename_scheme => :token
  end
  
  it "should pass on any unknown options to the has_many macro" do
    Document.expects(:has_many).with(:other_files, :as => :attachable, :order => :updated_at, :class_name => 'Document::OtherFile')
    Document.expects(:define_variants).with do |model, options|
      model == Document::OtherFile && options == { :process => process_proc, :class => MyVariant }
    end
    
    Document.has_attachments :other_files, :as => :attachable, :order => :updated_at,
                                           :process => process_proc, :class => MyVariant, :filename_scheme => :token
  end
  
  it "should not define an association if an association for the given name exists" do
    Document.expects(:has_one).never
    Document.expects(:define_variants).with do |model, options|
      model == Document::Watermark && options == {}
    end
    
    Document.expects(:has_many).never
    Document.expects(:define_variants).with do |model, options|
      model == Document::Image && options == {}
    end
    
    Document.has_attachment :watermark, :as => :attachable
    Document.has_attachments :images, :as => :attachable
  end
end

describe "AttachmentSan::Has, concerning defining attachment model subclasses" do
  it "should create an attachment model class when defining a single attachment association" do
    Document.reflect_on_association(:logo).klass.should == Document::Logo
    Document::Logo.superclass.should == AttachmentSan.attachment_class
  end
  
  it "should create an attachment model class when defining a collection attachment association" do
    Document.reflect_on_association(:images).klass.should == Document::Image
    Document::Image.superclass.should == AttachmentSan.attachment_class
  end
  
  it "should create different attachment model classes for different defining model classes" do
    Document::Logo.reflect_on_variant(:header)[:class].should == MyVariant
    
    OtherDocument.reflect_on_association(:logo).klass.should == OtherDocument::Logo
    OtherDocument::Logo.reflect_on_variant(:header)[:class].should == MyOtherVariant
  end
  
  it "should not look for existing constants outside the defining class's namespace" do
    class TotallyDifferent; end
    class Foo < TotallyDifferent; end
    
    Document.has_attachment :foo
    Document.reflect_on_association(:foo).klass.should == Document::Foo
  end
end

describe "AttachmentSan::Has, concerning a single associated attachment" do
  before do
    @document = Document.new
    @document.build_logo :uploaded_file => rails_icon
    @document.build_watermark :uploaded_file => rails_icon
  end
  
  it "should define a has_one association" do
    Document.reflect_on_association(:logo).macro.should == :has_one
  end
  
  it "should store the variant options on the new model class" do
    Document::Watermark.variant_reflections.length.should == 1
    Document::Watermark.variant_reflections.first[:name].should == :original
    Document::Watermark.variant_reflections.first[:class].should == AttachmentSan::Variant::Original
    
    Document::Logo.variant_reflections.length.should == 2
    Document::Logo.variant_reflections.last[:name].should == :header
    Document::Logo.variant_reflections.last[:class].should == MyVariant
  end
  
  it "should define only a default original variant if no other variants are given" do
    variant = @document.watermark.original
    variant.name.should == :original
    variant.should.be.instance_of AttachmentSan::Variant::Original
  end
  
  it "should define a default original variant and the ones specified" do
    %w{ original header }.each do |name|
      variant = @document.logo.send(name)
      variant.name.to_s.should == name
      variant.should.be.instance_of Document::Logo.reflect_on_variant(name)[:class]
    end
  end
end

describe "AttachmentSan::Has, concerning a collection of associated attachments" do
  before do
    @document = Document.new
    2.times { @document.images.build :uploaded_file => rails_icon }
    2.times { @document.misc_files.build :uploaded_file => rails_icon }
  end
  
  it "should define a has_many association" do
    Document.reflect_on_association(:images).macro.should == :has_many
  end
  
  it "should define only a default original variant if no others are given" do
    variants = @document.misc_files.map(&:original)
    variants.each { |v| v.name.should == :original }
    variants.each { |v| v.should.be.kind_of AttachmentSan::Variant }
  end
  
  it "should define a default original variant and the ones specified" do
    %w{ original thumbnail medium_sized download }.each do |name|
      variants = @document.images.map(&name.to_sym)
      variants.each { |v| v.name.to_s.should == name }
      variants.each { |v| v.should.be.kind_of AttachmentSan::Variant }
    end
  end
end

describe "AttachmentSan::Has, concerning attachment definitions with only a default original variant" do
  it "should pass the options hash on to the variant" do
    Document::MiscFile.variant_reflections.length.should == 1
    Document::MiscFile.variant_reflections.first[:name].should == :original
    Document::MiscFile.variant_reflections.first[:class].should == MyOriginal
    # Document::MiscFile.variant_reflections.first[:filename_scheme].should == :keep_original
    Document::MiscFile.variant_reflections.first[:process].call.should == :from_process_proc
  end
end

describe "AttachmentSan::Has, concerning attachment definitions overriding attachment base class options" do
  it "should merge the options onto the attachment_san_options of the attachment model subclass" do
    OtherDocument::Image.attachment_san_options[:base_path].should == '/other/base'
    OtherDocument::Image.attachment_san_options[:public_base_path].should == '/other/public'
  end
end