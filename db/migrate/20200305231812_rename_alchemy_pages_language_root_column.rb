# frozen_string_literal: true

class RenameAlchemyPagesLanguageRootColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :alchemy_pages, :language_root, :home_page
    add_index :alchemy_pages, [:home_page, :language_id]
  end
end
