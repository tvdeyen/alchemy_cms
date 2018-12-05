class CreateAlchemyEssences < ActiveRecord::Migration[5.2]
  def change
    create_table :alchemy_essences do |t|
      t.references :element, foreign_key: {to_table: :alchemy_elements}, index: true, null: false
      t.string :type, null: false
      if t.respond_to?(:jsonb)
        t.jsonb :ingredients # postgresql
      else
        t.json :ingredients # mysql and sqlite
      end
    end
    add_index :alchemy_essences, [:id, :type]
  end
end
