class Photo < ActiveRecord::Base
  attachment_san :allows => Mime::JPG
  after_upload :make_black
  
  has_one :thumbnail, :class => 'Photo'
  belongs_to :large_photo, :class => 'Photo'
  before_create :do_create_thumbnail
  
  def do_create_thumbnail
    unless large_photo
      create_thumbnail :uploaded_data = uploaded_data, :size => "<300x400"
    end
  end
end

# ---

class Photo < ActiveRecord::Base
  has_one :thumbnail
  has_one :full_size
  
  def uploaded_data=(data)
    build_thumbnail :uploaded_data => data
    build_full_size :uploaded_data => data
  end
end

class Attachment < ActiveRecord::Base
end

class Thumbnail < Attachment
  attachment_san :resizes_to => "<300x400"
  
  def resize(image)
    attachment.resize(image)
  end
end

class FullSize < Attachment
  attachment_san :resizes_to => "<600x800"
end