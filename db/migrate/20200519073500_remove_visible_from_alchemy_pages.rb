# frozen_string_literal: true
class RemoveVisibleFromAlchemyPages < ActiveRecord::Migration[5.2]
  def change
    remove_column :alchemy_pages, :visible, :boolean, default: false
  end
end
