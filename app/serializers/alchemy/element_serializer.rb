# frozen_string_literal: true

module Alchemy
  class ElementSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :position,
      :page_id,
      :cell_id,
      :tag_list,
      :created_at,
      :updated_at,
      :ingredients,
      :content_ids,
      :folded,
      :public,
      :preview_text,
      :display_name

    def filter(keys)
      if scope.can?(:manage, object)
        keys
      else
        keys - [:folded, :public, :preview_text, :display_name]
      end
    end

    has_many :nested_elements

    def ingredients
      object.contents.collect(&:serialize)
    end
  end
end
