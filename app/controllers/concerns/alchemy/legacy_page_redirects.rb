# frozen_string_literal: true

module Alchemy
  # Handles Legacy page redirects
  #
  # If the page could not be found via its url_path we try to find
  # a legacy page url for requested url to redirect to.
  #
  module LegacyPageRedirects
    extend ActiveSupport::Concern

    included do
      before_action :redirect_to_legacy_url,
        if: :redirect_to_legacy_url?,
        only: [:show]
    end

    private

    def redirect_to_legacy_url
      redirect_permanently_to legacy_page_redirect_url
    end

    def redirect_to_legacy_url?
      (@page.nil? || request.format.nil?) && last_legacy_url
    end

    # Use the bare minimum to redirect to legacy page
    #
    # Don't use query string of legacy url_path.
    # This drops the given query string.
    #
    def legacy_page_redirect_url
      page = last_legacy_url.page
      return unless page

      alchemy.show_page_path(
        locale: prefix_locale? ? page.language_code : nil,
        url_path: page.url_path,
      )
    end

    def legacy_urls
      # /slug/tree => slug/tree
      url_path = (request.fullpath[1..-1] if request.fullpath[0] == "/") || request.fullpath
      LegacyPageUrl.joins(:page).where(
        url_path: url_path,
        Page.table_name => {
          language_id: Language.current.id,
        },
      )
    end

    def last_legacy_url
      @_last_legacy_url ||= legacy_urls.last
    end
  end
end
