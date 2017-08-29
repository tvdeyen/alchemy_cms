# frozen_string_literal: true

module Alchemy
  class ContentSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :ingredient,
      :element_id,
      :position,
      :created_at,
      :updated_at,
      :settings,
      :label,
      :essence_class_name

    has_one :essence, polymorphic: true

    def filter(keys)
      if scope.can?(:manage, object)
        keys
      else
        keys - [:label, :essence_class_name]
      end
    end

    def ingredient
      object.serialized_ingredient
    end

    def essence_class_name
      object.essence_type.demodulize
    end

    def label
      object.name_for_label
    end
  end
end
