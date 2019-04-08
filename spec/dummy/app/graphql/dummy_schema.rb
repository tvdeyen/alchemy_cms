# frozen_string_literal: true

class DummySchema < GraphQL::Schema
  query(Alchemy::GraphQL::PageQuery)
end
