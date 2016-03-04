require_relative 'tasks/harden_acts_as_taggable_on_migrations'

module Alchemy
  class Upgrader::FourPointOne < Upgrader
    class << self
      def harden_acts_as_taggable_on_migrations
        desc 'Harden `acts_as_taggable_on_migrations`'
        `bundle exec rake railties:install:migrations FROM=acts_as_taggable_on_engine`
        Alchemy::Upgrader::Tasks::HardenActsAsTaggableOnMigrations.new.patch_migrations
        `bundle exec rake db:migrate`
      end

      def create_page_versions
        desc "Create versions for pages"
        Alchemy::Page.find_each do |page|
          next if page.systempage? || page.redirects_to_external?
          page.build_current_version(page_id: page.id)
          log "Created version for Page #{page.urlname}"
          if page.public?
            page.public_version = page.versions.last
            log "Created public version for Page #{page.urlname}"
          end
          page.save!
        end
      end

      def alchemy_4_1_todos
        notice = <<-NOTE

        Changed tagging provider to Gutentag
        ------------------------------------

        The automatic updater that just ran updated all existing `acts_as_taggable_on_migrations`,
        so that they don't blow up if the `acts_as_taggable_on` gem is no longer available.

        All your existing tags have been migrated to `Gutentag::Tag`s.

        Removed Rails and non-English translations
        ------------------------------------------

        Removed the Rails translations from our translation files and moved all non-english translation
        files into the newly introduced `alchemy_i18n` gem.

        If you need more translations than the default English one you can either put `alchemy_i18n`
        in to your apps `Gemfile` or - recommended - copy only the translation files you need into your
        apps `config/locales` folder.

        For the Rails translations either put the rails-i18n gem into your apps Gemfile or - recommended -
        copy only the translation files you need into your apps config/locales folder.

        NOTE
        todo notice, 'Alchemy v4.1 changes'
      end
    end
  end
end
