# frozen_string_literal: true

class CreateAlchemyEssencePictureAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :alchemy_essence_picture_assignments do |t|
      t.references :essence_picture,
        foreign_key: {to_table: :alchemy_essence_pictures},
        index: false,
        null: false
      t.references :picture,
        foreign_key: {to_table: :alchemy_pictures},
        index: false,
        null: false

      t.timestamps
    end
    add_index :alchemy_essence_picture_assignments, [:essence_picture_id, :picture_id],
      name: 'idx_essence_picture_assignments',
      unique: true
  end
end
