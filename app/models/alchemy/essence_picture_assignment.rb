module Alchemy
  class EssencePictureAssignment < BaseRecord
    belongs_to :essence_picture
    belongs_to :picture
  end
end
