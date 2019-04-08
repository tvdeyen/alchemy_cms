# frozen_string_literal: true

module Alchemy
  module GraphQL
    class ElementType < GraphQL::Schema::Object
      description "A Alchemy Element"

      field :id, ID, null: false
      field :page, PageType, null: true
      field :parent_element, self, null: true
      field :name, String, null: false
      field :contents, [ContentType], null: false
    end
  end
end
