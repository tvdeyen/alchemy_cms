# frozen_string_literal: true
class RenameUrlnameToUrlPath < ActiveRecord::Migration[5.2]
  def change
    rename_column :alchemy_legacy_page_urls, :urlname, :url_path
    rename_column :alchemy_pages, :urlname, :url_path
  end
end
