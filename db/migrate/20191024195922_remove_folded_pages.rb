class RemoveFoldedPages < ActiveRecord::Migration[5.0]
  def up
    drop_table :alchemy_folded_pages
  end

  def down
    create_table :alchemy_folded_pages do |t|
      t.integer "page_id", null: false
      t.integer "user_id", null: false
      t.boolean "folded", default: false
      t.index ["page_id", "user_id"], name: "index_alchemy_folded_pages_on_page_id_and_user_id", unique: true
    end
  end
end
