# frozen_string_literal: true

require 'webpacker'

module Alchemy
  class << self
    def webpacker
      @_webpacker ||= ::Webpacker::Instance.new(
        root_path: root_path,
        config_path: root_path.join('config/webpacker.yml')
      )
    end

    private

    def root_path
      @_root_path ||= Pathname.new(File.join(__dir__, '..', '..'))
    end
  end
end
