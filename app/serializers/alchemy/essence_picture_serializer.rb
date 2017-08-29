# frozen_string_literal: true

module Alchemy
  class EssencePictureSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :picture_id,
      :caption,
      :title,
      :alt_tag,
      :css_class,
      :link,
      :created_at,
      :updated_at,
      :thumbnail_url

    has_one :picture

    def filter(keys)
      if scope.can?(:manage, object)
        keys
      else
        keys - [:thumbnail_url]
      end
    end

    def link
      return if object.link.blank?
      {
        url: object.link,
        css_class: object.link_class_name,
        title: object.link_title,
        target: object.link_target
      }
    end
  end
end
