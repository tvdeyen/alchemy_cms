# frozen_string_literal: true

module Alchemy
  module Page::PageNaming
    extend ActiveSupport::Concern
    include NameConversions
    RESERVED_SLUGS = %w(admin messages new)

    included do
      before_validation :set_url_path,
        if: :renamed?,
        unless: -> { name.blank? }

      validates :name,
        presence: true
      validates :url_path,
        uniqueness: { scope: [:language_id, :layoutpage], if: -> { url_path.present? } },
        exclusion: { in: RESERVED_SLUGS },
        length: { minimum: 3, if: -> { url_path.present? } }

      before_save :set_title,
        if: -> { title.blank? }

      after_update :update_descendants_url_paths,
        if: :should_update_descendants_url_paths?

      after_move :update_url_path!,
        if: -> { Config.get(:url_nesting) }
    end

    # Returns true if name or url_path has changed.
    def renamed?
      name_changed? || url_path_changed?
    end

    # Makes a slug of all ancestors url_paths including mine and delimit them be slash.
    # So the whole path is stored as url_path in the database.
    def update_url_path!
      new_url_path = nested_url_path(slug)
      if url_path != new_url_path
        legacy_urls.create(url_path: url_path)
        update_column(:url_path, new_url_path)
      end
    end

    # Returns always the last part of a url_path path
    def slug
      url_path.to_s.split("/").last
    end

    # Returns an array of visible/non-language_root ancestors.
    def visible_ancestors
      return [] unless parent

      if new_record?
        parent.visible_ancestors.tap do |base|
          base.push(parent) if parent.visible?
        end
      else
        ancestors.visible.contentpages.where(language_root: nil).to_a
      end
    end

    private

    def should_update_descendants_url_paths?
      return false if !Config.get(:url_nesting)

      if active_record_5_1?
        saved_change_to_url_path? || saved_change_to_visible?
      else
        url_path_changed? || visible_changed?
      end
    end

    def update_descendants_url_paths
      reload
      descendants.each(&:update_url_path!)
    end

    def set_title
      self[:title] = name
    end

    # Sets the url_path to a url friendly slug.
    # Either from name, or if present, from url_path.
    # If url_nesting is enabled the url_path contains the whole path.
    def set_url_path
      if Config.get(:url_nesting)
        value = slug
      else
        value = url_path
      end
      self[:url_path] = nested_url_path(value)
    end

    def nested_url_path(value)
      (ancestor_slugs << converted_slug(value)).join("/")
    end

    # Slugs of all visible/non-language_root ancestors.
    # Returns [], if there is no parent, the parent is
    # the root page itself, or url_nesting is off.
    def ancestor_slugs
      return [] if !Config.get(:url_nesting) || parent.nil?

      visible_ancestors.map(&:slug).compact
    end

    # Converts the given name into an url friendly string.
    #
    # Names shorter than 3 will be filled up with dashes,
    # so it does not collidate with the language code.
    #
    def converted_slug(value)
      slug = convert_to_slug(value.blank? ? name : value)
      if slug.length < 3
        ("-" * (3 - slug.length)) + slug
      else
        slug
      end
    end
  end
end
