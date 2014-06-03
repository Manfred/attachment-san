require 'attachment_san'
ActiveRecord::Base.extend AttachmentSan::Initializer
ActiveRecord::Base.extend AttachmentSan::Has

require 'attachment_san/test/helper' if Rails.env == 'test'