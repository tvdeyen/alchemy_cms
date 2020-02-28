# frozen_string_literal: true

module Alchemy
  module Admin
    class LayoutpagesController < ResourcesController
      authorize_resource class: :alchemy_admin_layoutpages
      helper Alchemy::Admin::PagesHelper

      def index
        @query = Page.layoutpages.where(language: Language.current).ransack(search_filter_params[:q])
        @layoutpages = @query.result.page(params[:page] || 1).per(items_per_page)
        @languages = Language.on_current_site
      end

      def edit
        @page = Page.find(params[:id])
        @page_layouts = PageLayout.layouts_with_own_for_select(@page.page_layout, Language.current.id, true)
      end

      private

      def resource_handler
        @_resource_handler ||= Alchemy::Resource.new(controller_path, alchemy_module, Alchemy::Page)
      end
    end
  end
end
