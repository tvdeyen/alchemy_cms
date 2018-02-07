# frozen_string_literal: true

module Alchemy
  class EssenceFileSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :attachment_id,
      :title,
      :css_class

    has_one :attachment
  end
end
