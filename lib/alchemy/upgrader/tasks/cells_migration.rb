module Alchemy::Upgrader::Tasks
  class CellsMigration
    class Cell < ActiveRecord::Base
      self.table_name = 'alchemy_cells'
      belongs_to :page, class_name: 'Alchemy::Page'
    end

    def migrate_cells
      if ActiveRecord::Base.connection.data_source_exists?('alchemy_cells')
        cells = Cell.all

        if cells.any?
          cells.each do |cell|
            migrate_cell!(cell)
          end
          drop_cells
        else
          puts "No cells found. Skip"
        end
      else
        puts "Cells table does not exist. Skip"
      end
    end

    private

    def migrate_cell!(cell)
      fixed_element = Alchemy::Element.find_or_initialize_by(fixed: true, name: cell.name, page: cell.page)
      elements = Alchemy::Element.where(cell_id: cell.id)

      if fixed_element.new_record?
        fixed_element.nested_elements = elements
        fixed_element.save!
        puts "Created new fixed element '#{fixed_element.name}' for cell '#{cell.name}'."
      else
        puts "Element for cell '#{cell.name}' already present. Skip"
      end
    end

    def drop_cells
      RemoveAlchemyCells.new.up
    end

    class RemoveAlchemyCells < ActiveRecord::Migration[5.0]
      def up
        remove_column :alchemy_elements, :cell_id
        drop_table :alchemy_cells
      end
    end
  end
end
