require File.dirname(__FILE__) + '/helper'

describe "Attachment-San" do

  it "should save uploaded files" do
    Attachment.create :uploaded_data => uploaded_file('images/rails.png', 'image/png')
  end
end