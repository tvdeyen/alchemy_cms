# frozen_string_literal: true
namespace :alchemy do
  namespace :convert do
    namespace :url_paths do
      desc "Converts the url_path of all pages to nested url paths."
      task to_nested: [:environment] do
        unless Alchemy::Config.get(:url_nesting)
          raise "\nURL nesting is disabled! Please enable url_nesting in `config/alchemy/config.yml` first.\n\n"
        end

        puts "Converting..."
        pages = Alchemy::Page.contentpages
        count = pages.count
        pages.each_with_index do |page, n|
          puts "Updating page #{n + 1} of #{count}"
          page.update_url_path!
        end
        puts "Done."
      end

      desc "Converts the url_path of all pages to contain the slug only."
      task to_slug: [:environment] do
        if Alchemy::Config.get(:url_nesting)
          raise "\nURL nesting is enabled! Please disable url_nesting in `config/alchemy/config.yml` first.\n\n"
        end

        puts "Converting..."
        pages = Alchemy::Page.contentpages
        count = pages.count
        pages.each_with_index do |page, n|
          puts "Updating page #{n + 1} of #{count}"
          page.update_attribute :url_path, page.slug
        end
        puts "Done."
      end
    end
  end
end
