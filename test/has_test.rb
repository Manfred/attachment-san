require File.expand_path('../test_helper', __FILE__)

describe "AttachmentSan::Has" do
  it "should pass on any unknown options to the has_one macro" do
    Document.expects(:has_one).with(:other_file, :as => :attachable, :order => :updated_at)
    Document.expects(:define_variants).with(:other_file, :process => proc {}, :class => MyVariant, :filename_scheme => :token, :variants => [:hoge, :fuga])
    
    Document.has_attachment :other_file, :as => :attachable, :order => :updated_at,
                                         :process => proc {}, :class => MyVariant, :filename_scheme => :token, :variants => [:hoge, :fuga]
  end
  
  it "should pass on any unknown options to the has_many macro" do
    Document.expects(:has_many).with(:other_files, :as => :attachable, :order => :updated_at)
    Document.expects(:define_variants).with(:other_files, :process => proc {}, :class => MyVariant, :filename_scheme => :token, :variants => [:hoge, :fuga])
    
    Document.has_attachments :other_files, :as => :attachable, :order => :updated_at,
                                           :process => proc {}, :class => MyVariant, :filename_scheme => :token, :variants => [:hoge, :fuga]
  end
  
  it "should not define an association if an association for the given name exists" do
    Document.expects(:has_one).never
    Document.expects(:define_variants).with(:watermark, {})
    
    Document.expects(:has_many).never
    Document.expects(:define_variants).with(:images, {})
    
    Document.has_attachment :watermark, :as => :attachable
    Document.has_attachments :images, :as => :attachable
  end
end

describe "AttachmentSan::Has, concerning a single associated attachment" do
  before do
    @document = Document.new
    @document.build_logo :uploaded_file => rails_icon
    @document.build_watermark :uploaded_file => rails_icon
  end
  
  it "should create an attachment model class, nested under the defining model clas, and a has_one association" do
    reflection = Document.reflect_on_association(:logo)
    reflection.macro.should == :has_one
    reflection.klass.should == Document::Logo
    Document::Logo.superclass.should.be AttachmentSan.attachment_class
    Document::Logo.reflect_on_variant(:header)[:class].should.be MyVariant
  end
  
  it "should create different attachment model classes for different defining model classes" do
    reflection = OtherDocument.reflect_on_association(:logo)
    reflection.macro.should == :has_one
    reflection.klass.should == OtherDocument::Logo
    OtherDocument::Logo.superclass.should.be AttachmentSan.attachment_class
    OtherDocument::Logo.reflect_on_variant(:header)[:class].should.be MyOtherVariant
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
  
  it "should create an attachment model class, nested under the defining model clas, and a has_many association" do
    reflection = Document.reflect_on_association(:images)
    reflection.macro.should == :has_many
    reflection.klass.should == Document::Image
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

describe "AttachmentSan::Has, concerning attachment definitions with only a default original variant" do
  it "should pass the options hash on to the variant" do
    Document::MiscFile.variant_reflections.length.should == 1
    Document::MiscFile.variant_reflections.first[:name].should == :original
    Document::MiscFile.variant_reflections.first[:class].should == AttachmentSan::Variant::Original
    Document::MiscFile.variant_reflections.first[:filename_scheme].should == :keep_original
    Document::MiscFile.variant_reflections.first[:process].call.should == :from_process_proc
  end
end

describe "AttachmentSan::Has, concerning attachment definitions with an array of variants" do
  it "should simply assume the variant class exists" do
    @document = Document.new
    card = @document.address_cards.build(:uploaded_file => rails_icon)
    card.small_card.should.be.instance_of Document::AddressCard::SmallCard
    card.big_card.should.be.instance_of Document::AddressCard::BigCard
  end
end