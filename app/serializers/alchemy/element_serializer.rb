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

    has_many :contents, :nested_elements

    def filter(keys)
      if scope.can?(:manage, object)
        keys - [:content_ids, :ingredients]
      else
        keys - [:folded, :public, :preview_text, :display_name, :contents]
      end
    end

    def ingredients
      object.contents.collect(&:serialize)
    end
  end
end
