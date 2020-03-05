# frozen_string_literal: true

module Alchemy
  module Admin
    class PagesController < ResourcesController
      include OnPageLayout::CallbacksRunner

      helper 'alchemy/pages'

      before_action :set_translation,
        except: [:show]

      before_action :load_resource,
        only: [:show, :info, :unlock, :visit, :publish, :configure, :edit, :update, :destroy]

      authorize_resource class: Alchemy::Page, except: [:index]

      before_action :run_on_page_layout_callbacks,
        if: :run_on_page_layout_callbacks?,
        only: [:show]

      def index
        authorize! :index, :alchemy_admin_pages

        @language = Language.current
        @query = Alchemy::Page.contentpages.
          includes(:locker).
          where(language_id: @language.id).
          ransack(search_filter_params[:q])
        @pages = @query.result.page(params[:page] || 1).per(items_per_page)

        if @pages.empty?
          @page = Alchemy::Page.new(language: Alchemy::Language.current)
          @page_layouts = PageLayout.layouts_for_select(@language.id)
        end
      end

      # Used by page preview iframe in Page#edit view.
      #
      def show
        @preview_mode = true
        Page.current_preview = @page
        # Setting the locale to pages language, so the page content has it's correct translations.
        ::I18n.locale = @page.language.locale
        render(layout: Alchemy::Config.get(:admin_page_preview_layout) || 'application')
      end

      def info
        render layout: !request.xhr?
      end

      def new
        @page = Page.new(layoutpage: params[:layoutpage] == 'true', parent_id: params[:parent_id])
        @page_layouts = PageLayout.layouts_for_select(Language.current.id, @page.layoutpage?)
        @clipboard = get_clipboard('pages')
        @clipboard_items = Page.all_from_clipboard_for_select(@clipboard, Language.current.id, @page.layoutpage?)
      end

      def create
        @page = paste_from_clipboard || Page.new(page_params)
        if @page.save
          flash[:notice] = Alchemy.t("Page created", name: @page.name)
          do_redirect_to(redirect_path_after_create_page)
        else
          @page_layouts = PageLayout.layouts_for_select(Language.current.id, @page.layoutpage?)
          @clipboard = get_clipboard('pages')
          @clipboard_items = Page.all_from_clipboard_for_select(@clipboard, Language.current.id, @page.layoutpage?)
          render :new
        end
      end

      # Edit the content of the page and all its elements and contents.
      #
      # Locks the page to current user to prevent other users from editing it meanwhile.
      #
      def edit
        # fetching page via before filter
        if page_is_locked?
          flash[:warning] = Alchemy.t('This page is locked', name: @page.locker_name)
          redirect_to admin_pages_path
        elsif page_needs_lock?
          @page.lock_to!(current_alchemy_user)
        end
        @layoutpage = @page.layoutpage?
      end

      # Set page configuration like page names, meta tags and states.
      def configure
        @page_layouts = PageLayout.layouts_with_own_for_select(@page.page_layout, Language.current.id, @page.layoutpage?)
      end

      # Updates page
      #
      # * fetches page via before filter
      #
      def update
        # stores old page_layout value, because unfurtunally rails @page.changes does not work here.
        @old_page_layout = @page.page_layout
        if @page.update(page_params)
          @notice = Alchemy.t("Page saved", name: @page.name)
          @while_page_edit = request.referer.include?('edit')
        else
          configure
        end
      end

      # Fetches page via before filter, destroys it and redirects to page tree
      def destroy
        if @page.destroy
          flash[:notice] = Alchemy.t("Page deleted", name: @page.name)

          # Remove page from clipboard
          clipboard = get_clipboard('pages')
          clipboard.delete_if { |item| item['id'] == @page.id.to_s }
        end

        respond_to do |format|
          format.js do
            @redirect_url = if @page.layoutpage?
                              alchemy.admin_layoutpages_path
                            else
                              alchemy.admin_pages_path
                            end

            render :redirect
          end
        end
      end

      def link
        @attachments = Attachment.all.collect { |f|
          [f.name, download_attachment_path(id: f.id, name: f.urlname)]
        }
        @url_prefix = prefix_locale? ? "#{Language.current.code}/" : ""
      end

      # Leaves the page editing mode and unlocks the page for other users
      def unlock
        # fetching page via before filter
        @page.unlock!
        flash[:notice] = Alchemy.t(:unlocked_page, name: @page.name)
        @pages_locked_by_user = Page.from_current_site.locked_by(current_alchemy_user)
        respond_to do |format|
          format.js
          format.html {
            redirect_to params[:redirect_to].blank? ? admin_pages_path : params[:redirect_to]
          }
        end
      end

      def visit
        @page.unlock!
        redirect_to show_page_url(
          urlname: @page.urlname,
          locale: prefix_locale? ? @page.language_code : nil,
          host: @page.site.host == "*" ? request.host : @page.site.host
        )
      end

      # Sets the page public and updates the published_at attribute that is used as cache_key
      #
      def publish
        # fetching page via before filter
        @page.publish!
        flash[:notice] = Alchemy.t(:page_published, name: @page.name)
        redirect_back(fallback_location: admin_pages_path)
      end

      def flush
        Language.current.pages.flushables.update_all(published_at: Time.current)
        # We need to ensure, that also all layoutpages get the +published_at+ timestamp set,
        # but not set to public true, because the cache_key for an element is +published_at+
        # and we don't want the layout pages to be present in +Page.published+ scope.
        Language.current.pages.flushable_layoutpages.update_all(published_at: Time.current)
        respond_to { |format| format.js }
      end

      private

      def redirect_path_after_create_page
        if @page.editable_by?(current_alchemy_user)
          params[:redirect_to] || edit_admin_page_path(@page)
        else
          admin_pages_path
        end
      end

      def page_params
        params.require(:page).permit(*secure_attributes)
      end

      def secure_attributes
        if can?(:create, Alchemy::Page)
          Page::PERMITTED_ATTRIBUTES + [:home_page, :parent_id, :language_id, :language_code]
        else
          Page::PERMITTED_ATTRIBUTES
        end
      end

      def page_is_locked?
        return false if !@page.locker.try(:logged_in?)
        return false if !current_alchemy_user.respond_to?(:id)
        @page.locked? && @page.locker.id != current_alchemy_user.id
      end

      def page_needs_lock?
        return true unless @page.locker
        @page.locker.try!(:id) != current_alchemy_user.try!(:id)
      end

      def paste_from_clipboard
        if params[:paste_from_clipboard]
          source = Page.find(params[:paste_from_clipboard])
          parent = Page.find_by(id: params[:page][:parent_id]) || Page.root
          Page.copy_and_paste(source, parent, params[:page][:name])
        end
      end
    end
  end
end
