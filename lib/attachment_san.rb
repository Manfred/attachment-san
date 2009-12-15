require "attachment_san/core_ext"
require "attachment_san/has"
require "attachment_san/variant"

##
#
# AttachmentSan is an attachment extension for your model, it tries to be as
# flexible as possible.
#
# The only assumptions made, are that your model should have write accessors
# for +filename+ and +content_type+. And a read accessor for +token+, _if_ you
# intend to use that +:filename_scheme+ option.
#
# The base principle is; an attachment should store, and give access to, the
# original file. Besides that, an attachment could have an arbitray amount of
# ‘variants’. For instance, in the case of an image; a ‘thumbnail’ variant.
#
# A ‘variant’ does *nothing* besides providing path information about the file
# for said variant. Instead of trying to be ‘smart’ about image manipulation
# and the likes, it simply calls a user defined proc from where you can do
# whatever needs to be done.
#
# See the AttachmentSan::Initializer#attachment_san method to get started.
#
module AttachmentSan
  ##
  #
  # This module extends ActiveRecord::Base, which makes the attachment_san
  # method available as a class method on your model.
  #
  module Initializer
    ##
    #
    # Defines the model that it is called upon to be the attachment base model.
    # It will also include the AttachmentSan module. All attachment classes,
    # created by AttachmentSan, will inherit from said base model.
    #
    # You can give it a options hash with defaults for the variants.
    #
    # ==== Option parameters
    #
    # [+:base_path+]
    #   The file path to the public document root where the attachment files
    #   are to be stored.
    # [+:public_base_path+]
    #   The file path to the public document root to the root where the
    #   attachment files are to be stored.
    # [+:extension+]
    #   The scheme to use for the attachment variant extension. See
    #   Variant#extension for more information.
    # [+:filename_scheme+]
    #   The scheme to use for the attachment variant filename. See
    #   Variant#filename for more information.
    #
    # ==== Examples
    #
    #   class Attachment < ActiveRecord::Base
    #     attachment_san :base_path => Rails.root + 'public/files',
    #                    :filename_scheme => :variant_name
    #   end
    #
    #   AttachmentSan.attachment_class # => Attachment
    #
    def attachment_san(options = {})
      include AttachmentSan
      
      opt = self.attachment_san_options = {
        :public_base_path => '',
        :extension        => :keep_original,
        :filename_scheme  => :variant_name
      }.merge(options)
      # Defaults :base_path to expanded :public_base_path.
      opt[:base_path] ||= Rails.root + File.join('public', opt[:public_base_path])
      opt
    end
  end
  
  ##
  #
  # Returns the attachment model in which AttachmentSan is included.
  #
  mattr_accessor :attachment_class
  
  def self.included(model) #:nodoc:
    self.attachment_class = model
    model.extend Variant::ClassMethods
    
    model.class_inheritable_accessor :attachment_san_options
    model.define_callbacks :before_upload, :after_upload
    model.after_create :process_variants!
  end
  
  ##
  #
  # Returns the +uploaded_file+, but _only_ if the file has been assigned to
  # this instance. Returns +nil+ if this is an existing record.
  #
  attr_reader :uploaded_file
  
  ##
  #
  # Assigns the +filename+ and +content_type+ of the +uploaded_file+ to the
  # model. The +uploaded_file+ instance will be stored in the
  # <tt>@uploaded_file</tt> instance variable.
  #
  # Before the values are assigned, the +before_upload+ callback chain runs.
  # Likewise, after assigning the values, the +after_upload+ callback chain
  # runs.
  #
  # ==== Parameters
  #
  # [+uploaded_file+]
  #   The Tempfile object, that represents the upload, which you receive in a
  #   typical multiform request.
  #
  def uploaded_file=(uploaded_file)
    callback :before_upload
    
    @uploaded_file    = uploaded_file
    self.filename     = uploaded_file.original_filename
    self.content_type = uploaded_file.content_type.strip
    
    callback :after_upload
  end
  
  ##
  # 
  # Returns the filename’s extension, if available.
  #
  # ==== Examples
  #
  #   asset.filename # => "image.jpg"
  #   asset.extension # => "jpg"
  #
  #   asset.filename # => "Rakefile"
  #   asset.extension # => nil
  def extension
    filename.split('.').last if filename.include?('.')
  end
  
  ##
  #
  # Returns the filename _without_ its extension.
  #
  # ==== Examples
  #
  #   asset.filename # => "image.jpg"
  #   asset.filename_without_extension # => "image"
  #
  #   asset.filename # => "Rakefile"
  #   asset.filename_without_extension # => "Rakefile"
  #
  def filename_without_extension
    filename.include?('.') ? filename.split('.')[0..-2].join('.') : filename
  end
  
  ##
  #
  # Returns an array of Variant instances for this attachment model.
  #
  def variants
    self.class.variant_reflections.map { |reflection| send(reflection[:name]) }
  end
  
  ##
  #
  # Calls +process!+ on each variant instance returned by +variants+.
  #
  def process_variants!
    variants.each(&:process!)
  end
end