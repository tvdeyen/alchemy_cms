# frozen_string_literal: true

module Alchemy
  module Page::PageUsers
    extend ActiveSupport::Concern

    # Returns the creator of this page.
    #
    def creator
      super if Alchemy.user_class.respond_to?(:primary_key)
    end

    # Returns the last updater of this page.
    #
    def updater
      super if Alchemy.user_class.respond_to?(:primary_key)
    end

    # Returns the user currently editing this page.
    #
    def locker
      super if Alchemy.user_class.respond_to?(:primary_key)
    end

    # Returns the name of the creator of this page.
    #
    # If no creator could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def creator_name
      (creator && creator.try(:name)) || Alchemy.t('unknown')
    end

    # Returns the name of the last updater of this page.
    #
    # If no updater could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def updater_name
      (updater && updater.try(:name)) || Alchemy.t('unknown')
    end

    # Returns the name of the user currently editing this page.
    #
    # If no locker could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def locker_name
      (locker && locker.try(:name)) || Alchemy.t('unknown')
    end
  end
end
