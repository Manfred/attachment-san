class Photo < ActiveRecord::Base
  attachment_san :allows => Mime::JPG
end