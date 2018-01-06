# frozen_string_literal: true

module Alchemy
  module BaseHelper
    # An alias for truncate.
    # Left here for downwards compatibilty.
    def shorten(text, length)
      text.truncate(length: length)
    end

    # Logs a message in the Rails logger (warn level)
    # and optionally displays an error message to the user.
    def warning(message, text = nil)
      Logger.warn(message, caller(0..0))
      return unless text.present?
      render_message(:warning, text)
    end

    # Renders the flash partial (+alchemy/admin/partials/flash+)
    #
    # @param [String] notice The notice you want to display
    # @param [Symbol] style The style of this flash. Valid values are +:notice+ (default), +:warn+ and +:error+
    # @deprecated Render `alchemy/admin/partials/flash` directly instead.
    def render_flash_notice(notice, style = :notice)
      render('alchemy/admin/partials/flash', flash_type: style, message: notice)
    end
    deprecate render_flash_notice: 'Render `alchemy/admin/partials/flash` directly instead.',
      deprecator: Alchemy::Deprecation

    # Checks if the given argument is a String or a Page object.
    # If a String is given, it tries to find the page via page_layout
    # Logs a warning if no page is given.
    def page_or_find(page)
      if page.is_a?(String)
        page = Language.current.pages.find_by(page_layout: page)
      end
      if page.blank?
        warning("No Page found for #{page.inspect}")
        return
      else
        page
      end
    end
  end
end
