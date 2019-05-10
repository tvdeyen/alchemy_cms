# frozen_string_literal: true

require 'rails/generators/active_record/migration'

module Alchemy
  class CustomUserGenerator < Rails::Generators::NamedBase
    include ActiveRecord::Generators::Migration

    desc "Set up an Alchemy installation with a custom User class"

    source_root File.expand_path('templates', __dir__)

    def generate
      migration_template 'migration.rb.tt', "db/migrate/add_alchemy_roles_to_#{table_name}.rb"

      file_action = File.exist?('config/initializers/alchemy.rb') ? :append_file : :create_file
      send(file_action, 'config/initializers/alchemy.rb') do
        "Alchemy.user_class_name = '#{class_name}'"
      end
    end

    private

    def klass
      class_name.constantize
    end

    def table_name
      klass.table_name
    end
  end
end
