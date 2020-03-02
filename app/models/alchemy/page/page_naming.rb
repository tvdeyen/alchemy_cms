# frozen_string_literal: true

module Alchemy
  module Page::PageNaming
    extend ActiveSupport::Concern
    include NameConversions
    RESERVED_URLNAMES = %w(admin messages new)

    included do
      before_validation :set_urlname,
        if: :renamed?,
        unless: -> { name.blank? }

      validates :name,
        presence: true
      validates :urlname,
        uniqueness: {scope: [:language_id, :layoutpage], if: -> { urlname.present? }},
        exclusion:  {in: RESERVED_URLNAMES},
        length:     {minimum: 3, if: -> { urlname.present? }}

      before_save :set_title,
        if: -> { title.blank? }

      after_update :update_descendants_urlnames,
        if: :should_update_descendants_urlnames?

      after_move :update_urlname!
    end

    # Returns true if name or urlname has changed.
    def renamed?
      name_changed? || urlname_changed? || parent_id_changed?
    end

    # Makes a slug of all ancestors urlnames including mine and delimit them be slash.
    # So the whole path is stored as urlname in the database.
    def update_urlname!
      new_urlname = nested_url_name
      if urlname != new_urlname
        update!(urlname: new_urlname)
      end
    end

    # Returns always the last part of a urlname path
    def slug
      urlname.to_s.split('/').last
    end

    private

    def should_update_descendants_urlnames?
      if active_record_5_1?
        saved_change_to_urlname?
      else
        urlname_changed?
      end
    end

    def update_descendants_urlnames
      descendants.each(&:update_urlname!)
    end

    # Sets the urlname to a url friendly slug.
    # Either from name, or if present, from urlname.
    # If url_nesting is enabled the urlname contains the whole path.
    def set_urlname
      self[:urlname] = nested_url_name
    end

    def set_title
      self[:title] = name
    end

    # Converts the given name into an url friendly string.
    #
    # Names shorter than 3 will be filled up with dashes,
    # so it does not collidate with the language code.
    #
    def convert_url_name(value)
      url_name = convert_to_urlname(value.blank? ? name : value)
      if url_name.length < 3
        ('-' * (3 - url_name.length)) + url_name
      else
        url_name
      end
    end

    def nested_url_name
      parent ? "#{parent.urlname}/#{convert_url_name(slug)}" : convert_url_name(slug)
    end
  end
end
