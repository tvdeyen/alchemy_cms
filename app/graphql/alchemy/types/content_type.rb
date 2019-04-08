# frozen_string_literal: true

module Alchemy
  module GraphQL
    class ContentType < GraphQL::Schema::Object
      description "A Alchemy Content"

      field :id, ID, null: false
      field :element, ElementType, null: true
      field :name, String, null: false
      field :essence, EssenceType, null: false
    end
  end
end
