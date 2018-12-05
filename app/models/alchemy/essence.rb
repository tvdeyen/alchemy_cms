# frozen_string_literal: true

require 'active_record'

module Alchemy #:nodoc:
  # Delivers various methods we need for Essences in Alchemy.
  #
  # To turn a model into an essence inherit from this class and you will get:
  #   * validations
  #   * several getters (ie: page, element, ingredient, preview_text)
  #
  class Essence < BaseRecord
    attr_writer :validation_errors

    stampable stamper_class_name: Alchemy.user_class_name
    validate :validate_ingredient, on: :update, if: -> { validations.any? }

    belongs_to :element, class_name: "Alchemy::Element", touch: true
    has_one :page, through: :element, class_name: "Alchemy::Page"

    scope :available,    -> { joins(:element).merge(Alchemy::Element.available) }
    scope :from_element, ->(name) { joins(:element).where(Element.table_name => { name: name }) }

    delegate :restricted?, to: :page,    allow_nil: true
    delegate :trashed?,    to: :element, allow_nil: true
    delegate :public?,     to: :element, allow_nil: true

    class << self
      # Turn any active record model into an essence by calling this class method
      #
      # @option options [String || Symbol] ingredient_column ('body')
      #   specifies the column name you use for storing the content in the database (default: +body+)
      # @option options [String || Symbol] validate_column (ingredient_column)
      #   The column the the validations run against.
      # @option options [String || Symbol] preview_text_column (ingredient_column)
      #   Specify the column for the preview_text method.
      #
      def acts_as_essence(options = {})
        register_as_essence_association!
        ingredient_column = options[:ingredient_column] || :body
        store_accessor :ingredients, ingredient_column

        define_method :ingredient_column do
          ingredient_column
        end
      end

      # Register the current class as has_many association on +Alchemy::Page+ and +Alchemy::Element+ models
      def register_as_essence_association!
        klass_name = model_name.to_s
        arguments = [:has_many, klass_name.demodulize.tableize.to_sym, through: :contents,
          source: :essence, source_type: klass_name]
        %w(Page Element).each { |k| "Alchemy::#{k}".constantize.send(*arguments) }
      end
    end

    def validation_column
      ingredient_column
    end

    def preview_text_column
      ingredient_column
    end

    def acts_as_essence_class
      self.class
    end

    # Essence Validations:
    #
    # Essence validations can be set inside the config/elements.yml file.
    #
    # Supported validations are:
    #
    # * presence
    # * uniqueness
    # * format
    #
    # format needs to come with a regex or a predefined matcher string as its value.
    # There are already predefined format matchers listed in the config/alchemy/config.yml file.
    # It is also possible to add own format matchers there.
    #
    # Example of format matchers in config/alchemy/config.yml:
    #
    # format_matchers:
    #   email: !ruby/regexp '/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/'
    #   url:   !ruby/regexp '/\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix'
    #   ssl:   !ruby/regexp '/https:\/\/[\S]+/'
    #
    # Example of an element definition with essence validations:
    #
    #   - name: person
    #     contents:
    #     - name: name
    #       type: EssenceText
    #       validate: [presence]
    #     - name: email
    #       type: EssenceText
    #       validate: [format: 'email']
    #     - name: homepage
    #       type: EssenceText
    #       validate: [format: !ruby/regexp '^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$']
    #
    # Example of an element definition with chained validations.
    #
    #   - name: person
    #     contents:
    #     - name: name
    #       type: EssenceText
    #       validate: [presence, uniqueness, format: 'name']
    #
    def validate_ingredient
      validations.each do |validation|
        if validation.respond_to?(:keys)
          validation.map do |key, value|
            send("validate_#{key}", value)
          end
        else
          send("validate_#{validation}")
        end
      end
    end

    def validations
      @validations ||= definition.present? ? definition['validate'] || [] : []
    end

    def validation_errors
      @validation_errors ||= []
    end

    def validate_presence(validate = true)
      if validate && ingredient.blank?
        errors.add(ingredient_column, :blank)
        validation_errors << :blank
      end
    end

    def validate_uniqueness(validate = true)
      return if !validate || !public?
      if duplicates.any?
        errors.add(ingredient_column, :taken)
        validation_errors << :taken
      end
    end

    def validate_format(format)
      matcher = Config.get('format_matchers')[format] || format
      if ingredient.to_s.match(Regexp.new(matcher)).nil?
        errors.add(ingredient_column, :invalid)
        validation_errors << :invalid
      end
    end

    def duplicates
      acts_as_essence_class
        .available
        .from_element(element.name)
        .where(ingredient_column.to_s => ingredient)
        .where.not(id: id)
    end

    # Returns the value stored from the database column that is configured as ingredient column.
    def ingredient
      send(ingredient_column)
    end

    # Returns the value stored from the database column that is configured as ingredient column.
    def ingredient=(value)
      send(ingredient_setter_method, value)
    end

    # Returns the setter method for ingredient column
    def ingredient_setter_method
      "#{ingredient_column}="
    end

    # Essence definition from config/elements.yml
    def definition
      return {} if element.nil? || element.content_definitions.nil?
      element.content_definitions.detect { |c| c['name'] == content.name } || {}
    end

    # Touch content. Called after update.
    def touch_content
      return nil if content.nil?
      content.touch
    end

    # Returns the first x (default 30) characters of ingredient for the Element#preview_text method.
    #
    def preview_text(maxlength = 30)
      send(preview_text_column).to_s[0..maxlength - 1]
    end

    def open_link_in_new_window?
      respond_to?(:link_target) && link_target == 'blank'
    end

    def partial_name
      self.class.name.split('::').last.underscore
    end

    def acts_as_essence?
      acts_as_essence_class.present?
    end

    def to_partial_path
      "alchemy/essences/#{partial_name}_view"
    end

    def has_tinymce?
      false
    end
  end
end
