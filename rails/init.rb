require 'attachment_san'
ActiveRecord::Base.extend AttachmentSan::Initializer

require 'attachment_san/test/helper' if Rails.env == 'test'