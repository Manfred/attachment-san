require File.expand_path('../test_helper', __FILE__)

# class Document < ActiveRecord::Base
#   attachment_san :keep_filename => true
# end
# 
# class Drawing < Document
#   attachment_san :accept => Mime::PNG
# end
# 
# class DrawingThumbnail < Document
#   attachment_san :accept => Mime::PNG, :keep_filename => false
# end

class Attachment < ActiveRecord::Base
  attr_accessor :file_before_upload
  before_upload { |record| record.file_before_upload = record.uploaded_file }
  
  attr_accessor :file_after_upload
  after_upload  { |record| record.file_after_upload  = record.uploaded_file }
end

describe "AttachmentSan, class methods" do
  before do
    @upload = rails_icon
    @attachment = Attachment.new(:uploaded_file => @upload)
  end
  
  it "should call a before_upload filter chain before actually assigning the new uploaded file" do
    new_upload = rails_icon
    @attachment.uploaded_file = new_upload
    @attachment.file_before_upload.should.be @upload
  end
  
  it "should call an after_upload filter chain after assigning the new uploaded file" do
    @attachment.file_after_upload.should.be @upload
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
end