# frozen_string_literal: true

module Alchemy
  class PageTreeSerializer < BaseSerializer
    def attributes
      {'page' => nil}
    end

    def page
      page_hash(object, object.children.map { |c| page_hash(c) })
    end

    protected

    def page_hash(page, children = [])
      p_hash = {
        id: page.id,
        name: page.name,
        public: page.public?,
        visible: page.visible?,
        restricted: page.restricted?,
        page_layout: page.page_layout,
        slug: page.slug,
        redirects_to_external: page.redirects_to_external?,
        urlname: page.urlname,
        external_urlname: page.redirects_to_external? ? page.external_urlname : nil,
        level: page.level,
        root: page.root?,
        root_or_leaf: page.root? || page.leaf?,
        children: children
      }

      if opts[:elements]
        p_hash.update(elements: ActiveModel::Serializer::CollectionSerializer.new(page_elements(page)))
      end

      if opts[:ability].can?(:index, :alchemy_admin_pages)
        p_hash.merge({
          definition_missing: page.definition.blank?,
          folded: children.empty?,
          locked: page.locked?,
          locked_notice: page.locked? ? Alchemy.t('This page is locked', name: page.locker_name) : nil,
          permissions: page_permissions(page, opts[:ability]),
          status_titles: page_status_titles(page)
        })
      else
        p_hash
      end
    end

    def page_elements(page)
      if opts[:elements] == 'true'
        page.elements
      else
        page.elements.named(opts[:elements].split(',') || [])
      end
    end

    def page_permissions(page, ability)
      {
        info: ability.can?(:info, page),
        configure: ability.can?(:configure, page),
        copy: ability.can?(:copy, page),
        destroy: ability.can?(:destroy, page),
        create: ability.can?(:create, Alchemy::Page),
        edit_content: ability.can?(:edit_content, page)
      }
    end

    def page_status_titles(page)
      {
        public: page.status_title(:public),
        visible: page.status_title(:visible),
        restricted: page.status_title(:restricted)
      }
    end
  end
end
