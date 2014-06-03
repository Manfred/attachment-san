# Variant:
# * Returns path information
# * /a2/e0/dd/fits_within_200x200.jpg - "many many files"
# * /organizations/12/logos/main.jpg - "one or two files"
# * /cant/guess/me/82734mhsdf923184jnshdf91238ukjhsdf.jpg - "secret location"


member.avatar.medium # => member.avatar.image('fits_within_8x8')

company.logo.original # => 

{ :company => { :logo => { :data => IOWEETIKVEEL } } }

# abstract model for data about a file, and has variants, defined by the model that has attachments
class Attachment
  belongs_to :attachable
  
  include Att # makes this an attachment model
end

class Member
  extend Att::Has # adds declerative class methods
  include Att::Variant # defines filters to handle variants
  
  attaches_one :avatar
  attaches_many 
  
  has_attachment :avatar, :variants => {
    'medium' => { ... }, # => Class.new(Att:Variant)
    'fits_within_80x80' => { :fits_within => [80, 80] }
  }
end

# TODO
# * filters on a variant basis?
# * actual sizes
# * module Variants
#     class Medium
#       undef :foo
#     end
#   end