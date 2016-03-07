class ChangeElementsPageAssociationToPageVersion < ActiveRecord::Migration[5.0]
  def up
    remove_index :alchemy_elements, [:page_id, :parent_element_id]
    remove_foreign_key :alchemy_elements, name: :alchemy_elements_page_id_fkey

    rename_column :alchemy_elements, :page_id, :page_version_id

    add_index :alchemy_elements, [:page_version_id, :parent_element_id],
      name: 'alchemy_elements_page_version_parent_element_idx'
    add_foreign_key :alchemy_elements, :alchemy_page_versions,
      column: :page_version_id,
      on_update: :cascade,
      on_delete: :cascade,
      name: :alchemy_elements_page_version_id_fkey

    Alchemy::Element.find_each do |element|
      next unless element.page
      version = element.page.public_version || element.page.current_version
      element.update(page_version: version)
      say "Assign element #{element.id} to #{version.id}"
    end
  end

  def down
    remove_index :alchemy_elements, name: 'alchemy_elements_page_version_parent_element_idx'
    remove_foreign_key :alchemy_elements, name: :alchemy_elements_page_version_id_fkey

    rename_column :alchemy_elements, :page_version_id, :page_id

    add_index :alchemy_elements, [:page_id, :parent_element_id]
    add_foreign_key :alchemy_elements, :alchemy_pages,
      column: :page_id,
      on_update: :cascade,
      on_delete: :cascade,
      name: :alchemy_elements_page_id_fkey

    Alchemy::Element.find_each do |element|
      page = element.page
      element.update(page: page)
      say "Set element #{element.id} page to #{page.id}"
    end
  end
end
