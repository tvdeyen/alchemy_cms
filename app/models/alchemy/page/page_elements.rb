# frozen_string_literal: true

module Alchemy
  module Page::PageElements
    extend ActiveSupport::Concern

    included do
      attr_accessor :do_not_autogenerate

      has_many :elements,
        -> { order(:position).not_nested.not_fixed.not_trashed },
        class_name: 'Alchemy::Element'
      has_many :elements_including_fixed,
        -> { order(:position).not_nested.not_trashed },
        class_name: 'Alchemy::Element'
      has_many :trashed_elements,
        -> { Element.trashed.order(:position) },
        class_name: 'Alchemy::Element'
      has_many :fixed_elements,
        -> { order(:position).fixed.not_trashed },
        class_name: 'Alchemy::Element'
      has_many :descendent_elements,
        -> { order(:position).not_fixed.not_trashed },
        class_name: 'Alchemy::Element'
      has_many :contents, through: :elements
      has_many :descendent_contents,
        through: :descendent_elements,
        class_name: 'Alchemy::Content',
        source: :contents
      has_and_belongs_to_many :to_be_swept_elements, -> { distinct },
        class_name: 'Alchemy::Element',
        join_table: ElementToPage.table_name

      after_create :autogenerate_elements, unless: -> { systempage? || do_not_autogenerate }

      after_update :trash_not_allowed_elements!,
        if: :has_page_layout_changed?

      after_update :autogenerate_elements,
        if: :has_page_layout_changed?
    end

    module ClassMethods
      # Copy page elements
      #
      # @param source [Alchemy::Page]
      # @param target [Alchemy::Page]
      # @return [Array]
      #
      def copy_elements(source, target)
        new_elements = []
        source.elements.not_trashed.each do |source_element|
          new_element = Element.copy(source_element, {
            page_id: target.id
          })
          new_element.move_to_bottom
          new_elements << new_element
        end
        new_elements
      end
    end

    # Finds elements of page.
    #
    # @param [Hash]
    #   options hash
    # @param [Boolean] (false)
    #   Pass true, if you want to also have not published elements.
    #
    # @option options [Array] only
    #   Returns only elements with given names
    # @option options [Array] except
    #   Returns all elements except the ones with given names
    # @option options [Fixnum] count
    #   Limit the count of returned elements
    # @option options [Fixnum] offset
    #   Starts with an offset while returning elements
    # @option options [Boolean] random (false)
    #   Return elements randomly shuffled
    # @option options [Alchemy::Element || String] from_fixed_element
    #   Return nested elements from given fixed element
    #
    # @return [ActiveRecord::Relation]
    #
    def find_elements(options = {}, show_non_public = false)
      if options[:from_cell]
        Alchemy::Deprecation.new('Using `from_cell` is deprecated and will be removed in Alchemy 5. Please use `from_fixed_element` instead.')
      end
      fixed_element = options[:from_fixed_element] || options[:from_cell]
      elements = elements_from_fixed_element_or_self(fixed_element)
      if options[:only].present?
        elements = elements.named(options[:only])
      elsif options[:except].present?
        elements = elements.excluded(options[:except])
      end
      if options[:reverse_sort] || options[:reverse]
        elements = elements.reverse_order
      end
      elements = elements.offset(options[:offset]).limit(options[:count])
      if options[:random]
        elements = elements.order("RAND()")
      end
      show_non_public ? elements : elements.published
    end
    alias_method :find_selected_elements, :find_elements

    # All available element definitions that can actually be placed on current page.
    #
    # It extracts all definitions that are unique or limited and already on page.
    #
    # == Example of unique element:
    #
    #   - name: headline
    #     unique: true
    #     contents:
    #     - name: headline
    #       type: EssenceText
    #
    # == Example of limited element:
    #
    #   - name: article
    #     amount: 2
    #     contents:
    #     - name: text
    #       type: EssenceRichtext
    #
    def available_element_definitions(only_element_named = nil)
      @_element_definitions ||= if only_element_named
        definition = Element.definition_by_name(only_element_named)
        element_definitions_by_name(definition['nestable_elements'])
      else
        element_definitions
      end

      return [] if @_element_definitions.blank?

      @_existing_element_names = elements_including_fixed.pluck(:name)
      delete_unique_element_definitions!
      delete_outnumbered_element_definitions!

      @_element_definitions
    end

    # All names of elements that can actually be placed on current page.
    #
    def available_element_names
      @_available_element_names ||= available_element_definitions.map { |e| e['name'] }
    end

    # Available element definitions excluding nested unique elements.
    #
    def available_elements_within_current_scope(parent)
      @_available_elements = if parent
        parents_unique_nested_elements = parent.nested_elements.where(unique: true).pluck(:name)
        available_element_definitions(parent.name).reject do |e|
          parents_unique_nested_elements.include? e['name']
        end
      else
        available_element_definitions
      end
    end

    # All element definitions defined for page's page layout
    #
    # Warning: Since elements can be unique or limited in number,
    # it is more safe to ask for +available_element_definitions+
    #
    def element_definitions
      @_element_definitions ||= element_definitions_by_name(element_definition_names)
    end

    # All element definitions defined for page's page layout including nestable element definitions
    #
    def descendent_element_definitions
      definitions = element_definitions_by_name(element_definition_names)
      definitions.select { |d| d.key?('nestable_elements') }.each do |d|
        definitions += element_definitions_by_name(d['nestable_elements'])
      end
      definitions.uniq { |d| d['name'] }
    end

    # All names of elements that are defined in the page definition.
    #
    # Assign elements to a page in +config/alchemy/page_layouts.yml+.
    #
    # == Example of page_layouts.yml:
    #
    #   - name: contact
    #     elements: [headline, contactform]
    #
    def element_definition_names
      definition['elements'] || []
    end
    alias_method :element_names_from_definition, :element_definition_names
    deprecate element_names_from_definition: :element_definition_names, deprecator: Alchemy::Deprecation

    # Element definitions with given name(s)
    #
    # @param [Array || String]
    #   one or many Alchemy::Element names. Pass +'all'+ to get all Element definitions
    # @return [Array]
    #   An Array of element definitions
    #
    def element_definitions_by_name(names)
      return [] if names.blank?

      if names.to_s == "all"
        Element.definitions
      else
        Element.definitions.select { |e| names.include? e['name'] }
      end
    end

    # Returns all elements that should be feeded via rss.
    #
    # Define feedable elements in your +page_layouts.yml+:
    #
    #   - name: news
    #     feed: true
    #     feed_elements: [element_name, element_2_name]
    #
    def feed_elements
      elements.available.named(definition['feed_elements'])
    end

    # Returns an array of all EssenceRichtext contents ids from not folded elements
    #
    def richtext_contents_ids
      descendent_contents
        .where(Element.table_name => {folded: false})
        .select(&:has_tinymce?)
        .collect(&:id)
    end

    private

    # Looks in the page_layout descripion, if there are elements to autogenerate.
    #
    # And if so, it generates them.
    #
    def autogenerate_elements
      elements_already_on_page = elements.not_trashed.pluck(:name)
      definition.fetch('autogenerate', []).each do |element_name|
        next if elements_already_on_page.include?(element_name)
        Element.create_from_scratch(page: self, name: element_name)
      end
    end

    # Trashes all elements that are not allowed for this page_layout.
    def trash_not_allowed_elements!
      not_allowed_elements = elements.where([
        "#{Element.table_name}.name NOT IN (?)",
        element_definition_names
      ])
      not_allowed_elements.to_a.map(&:trash!)
    end

    def has_page_layout_changed?
      if active_record_5_1?
        saved_change_to_page_layout?
      else
        page_layout_changed?
      end
    end

    # Deletes unique and already present definitions from @_element_definitions.
    #
    def delete_unique_element_definitions!
      @_element_definitions.delete_if do |element|
        element['unique'] && @_existing_element_names.include?(element['name'])
      end
    end

    # Deletes limited and outnumbered definitions from @_element_definitions.
    #
    def delete_outnumbered_element_definitions!
      @_element_definitions.delete_if do |element|
        outnumbered = @_existing_element_names.select { |name| name == element['name'] }
        element['amount'] && outnumbered.count >= element['amount'].to_i
      end
    end

    # Returns elements either from given fixed element or self
    #
    def elements_from_fixed_element_or_self(fixed_element)
      case fixed_element
      when Alchemy::Element
        fixed_element.nested_elements
      when String
        fixed_element_elements_by_name(fixed_element)
      else
        elements.not_fixed
      end
    end

    # Returns all elements from given fixed element name
    #
    def fixed_element_elements_by_name(name)
      fixed_element = elements.fixed.find_by(name: name)
      if fixed_element
        fixed_element.nested_elements
      else
        Alchemy::Logger.warn("Fixed element with name `#{name}` could not be found!", caller(0..0))
        Element.none
      end
    end
  end
end
