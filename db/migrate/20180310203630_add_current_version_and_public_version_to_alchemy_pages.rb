class AddCurrentVersionAndPublicVersionToAlchemyPages < ActiveRecord::Migration[5.0]
  def up
    add_reference :alchemy_pages, :current_version, index: true
    add_reference :alchemy_pages, :public_version, index: true
  end

  def down
    remove_reference :alchemy_pages, :current_version, index: true
    remove_reference :alchemy_pages, :public_version, index: true
  end
end
