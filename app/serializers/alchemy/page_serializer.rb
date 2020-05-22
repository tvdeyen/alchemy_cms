# frozen_string_literal: true

module Alchemy
  class PageSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :url_path,
      :page_layout,
      :title,
      :language_code,
      :meta_keywords,
      :meta_description,
      :tag_list,
      :created_at,
      :updated_at,
      :status

    has_many :elements
  end
end
