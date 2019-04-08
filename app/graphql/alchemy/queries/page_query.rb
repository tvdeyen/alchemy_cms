# frozen_string_literal: true

module Alchemy
  module GraphQL
    class PageQuery < GraphQL::Schema::Object
      field :page, PageType, null: true do
        description "Find Alchemy Page by name"
        argument :name, String, required: true
      end

      def page(name:)
        Alchemy::Page.find_by(name: name)
      end
    end
  end
end
