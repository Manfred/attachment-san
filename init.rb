require 'active_record/attachment_san'

ActiveRecord::Base.send(:extend, ActiveRecord::AttachmentSan::ClassMethods)