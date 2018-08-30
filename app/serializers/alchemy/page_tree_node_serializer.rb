# frozen_string_literal: true

module Alchemy
  class PageTreeNodeSerializer < Panko::Serializer
    attributes(
      :id,
      :name,
      :public,
      :visible,
      :folded,
      :locked,
      :restricted,
      :page_layout,
      :redirects_to_external,
      :urlname,
      :level,
      :external_urlname,
      :root,
      :definition_missing,
      :locked_notice,
      :permissions,
      :status_titles,
      :has_children
    )

    private

    alias_method :page, :object

    def has_children
      page.children.any?
    end

    def public
      page.public?
    end

    def visible
      page.visible?
    end

    def folded
      true
    end

    def locked
      page.locked?
    end

    def restricted
      page.restricted?
    end

    def redirects_to_external
      page.redirects_to_external?
    end

    def level
      page.depth
    end

    def external_urlname
      page.redirects_to_external? ? page.external_urlname : nil
    end

    def root
      level == 1
    end

    def definition_missing
      page.definition.blank?
    end

    def locked_notice
      page.locked? ? Alchemy.t('This page is locked', name: page.locker_name) : nil
    end

    def permissions
      ability = scope[:ability]
      {
        info: ability.can?(:info, page),
        configure: ability.can?(:configure, page),
        copy: ability.can?(:copy, page),
        destroy: ability.can?(:destroy, page),
        create: ability.can?(:create, Alchemy::Page),
        edit_content: ability.can?(:edit_content, page)
      }
    end

    def status_titles
      {
        public: page.status_title(:public),
        visible: page.status_title(:visible),
        restricted: page.status_title(:restricted)
      }
    end
  end
end
