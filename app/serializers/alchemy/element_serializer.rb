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
      :display_name,
      :nestable_elements,
      :has_validations

    has_many :contents, :nested_elements

    def filter(keys)
      if scope.can?(:manage, object)
        keys - [:content_ids, :ingredients]
      else
        keys - [:folded, :public, :preview_text, :display_name, :contents, :nestable_elements, :has_validations]
      end
    end

    has_many :nested_elements

    def ingredients
      object.contents.collect(&:serialize)
    end

    def has_validations
      object.has_validations?
    end
  end
end
