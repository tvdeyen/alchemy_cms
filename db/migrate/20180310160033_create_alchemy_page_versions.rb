class CreateAlchemyPageVersions < ActiveRecord::Migration[5.0]
  def change
    create_table :alchemy_page_versions do |t|
      t.references :page, index: true, foreign_key: {
        to_table: :alchemy_pages,
        on_update: :cascade,
        on_delete: :cascade,
        name: :alchemy_page_versions_page_id_fkey
      }
      t.string :title
    end
  end
end
