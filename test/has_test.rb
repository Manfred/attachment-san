require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan::Has, concerning a single associated attachment" do
  before do
    @document = Document.new
    @document.build_logo :uploaded_file => rails_icon
    @document.build_watermark :uploaded_file => rails_icon
  end
  
  it "should create a model class and a has_one association" do
    reflection = Document.reflect_on_association(:logo)
    reflection.macro.should == :has_one
    reflection.klass.should == Logo
    Logo.superclass.should.be AttachmentSan.attachment_class
  end
  
  it "should store the variant options on the new model class" do
    Watermark.variant_reflections.length.should == 1
    Watermark.variant_reflections.first[:name].should == :original
    Watermark.variant_reflections.first[:class].should == AttachmentSan::Variant::Original
    
    Logo.variant_reflections.length.should == 2
    Logo.variant_reflections.last[:name].should == :header
    Logo.variant_reflections.last[:class].should == MyVariant
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
      variant.should.be.instance_of Logo.reflect_on_variant(name)[:class]
    end
  end
end

describe "AttachmentSan::Has, concerning a collection of associated attachments" do
  before do
    @document = Document.new
    2.times { @document.images.build :uploaded_file => rails_icon }
    2.times { @document.misc_files.build :uploaded_file => rails_icon }
  end
  
  it "should create a model class and a has_many association" do
    reflection = Document.reflect_on_association(:images)
    reflection.macro.should == :has_many
    reflection.klass.should == Image
  end
  
  it "should define only a default original variant if no others are given" do
    variants = @document.misc_files.map(&:original)
    variants.should.all { |v| v.name == :original }
    variants.should.all { |v| v.instance_of? AttachmentSan::Variant }
  end
  
  it "should define a default original variant and the ones specified" do
    %w{ original thumbnail medium_sized download }.each do |name|
      variants = @document.images.map(&name.to_sym)
      variants.should.all { |v| v.name == name }
      variants.should.all { |v| v.instance_of? AttachmentSan::Variant }
    end
  end
end