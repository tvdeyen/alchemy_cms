# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Alchemy::EssencePictureAssignment do
  it { is_expected.to belong_to(:essence_picture).class_name("Alchemy::EssencePicture") }
  it { is_expected.to belong_to(:picture).class_name("Alchemy::Picture") }
end
