# frozen_string_literal: true

module Alchemy
  class AttachmentSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :file_name,
      :file_mime_type,
      :file_size,
      :tag_list,
      :created_at,
      :updated_at,
      :icon_css_class

    def filter(keys)
      if scope.can?(:manage, object)
        keys
      else
        keys - [:icon_css_class]
      end
    end
  end
end
