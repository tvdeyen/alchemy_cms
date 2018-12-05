# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_links
#
#  id              :integer          not null, primary key
#  link            :string
#  link_title      :string
#  link_target     :string
#  link_class_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  updater_id      :integer
#

module Alchemy
  class EssenceLink < Essence
    acts_as_essence ingredient_column: 'link'

    store_accessor :ingredients,
      :link,
      :link_target,
      :link_title,
      :link_class_name
  end
end
