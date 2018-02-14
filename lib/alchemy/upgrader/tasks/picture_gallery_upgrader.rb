require 'thor'
require 'alchemy/upgrader'

module Alchemy::Upgrader::Tasks
  class PictureGalleryUpgrader < Thor
    include Thor::Actions

    GALLERY_PICTURES_ERB_REGEXP = /<%.*element.contents.gallery_pictures.*/
    GALLERY_PICTURES_HAML_REGEXP = /-.*element.contents.gallery_pictures.*/
    GALLERY_PICTURES_EDITOR_REGEXP = /.*render_picture_gallery_editor.*/

    no_tasks do
      def convert_picture_galleries
        config = read_config
        unless config
          puts "\nNo elements config found. Skipping."
          return
        end

        elements_with_picture_gallery, all_other_elements = config.partition do |e|
          e['picture_gallery']
        end

        if elements_with_picture_gallery.empty?
          puts "No elements with `picture_gallery` found. Skipping."
          return
        end

        convert_to_nestable_elements(elements_with_picture_gallery, all_other_elements)
        backup_config
        write_config(all_other_elements)
        find_gallery_pictures_rendering
        remove_gallery_pictures_editor

        puts "Generate new element partials for nestable elements"
        system "rails g alchemy:elements --skip"
      end
    end

    private

    def read_config
      print "1. Reading `config/alchemy/elements.yml` ... "

      old_config_file = Rails.root.join('config', 'alchemy', 'elements.yml')
      config = YAML.load_file(old_config_file)

      if config
        puts "done.\n"
      end

      config
    end

    def convert_to_nestable_elements(elements_with_picture_gallery, all_other_elements)
      print '2. Converting picture gallery elements into `nestable_elements` ... '

      elements_with_picture_gallery.inject(all_other_elements) do |elements, old_element|
        elements << modify_old_element(old_element.dup)
        elements << build_new_element(old_element)
      end

      puts 'done.'
    end

    def backup_config
      print "3. Copy existing config file to `config/alchemy/elements.yml.old` ... "

      FileUtils.copy Rails.root.join('config', 'alchemy', 'elements.yml'),
                     Rails.root.join('config', 'alchemy', 'elements.yml.old')

      puts "done.\n"
    end

    def write_config(config)
      print '4. Writing new `config/alchemy/elements.yml` ... '

      File.open(Rails.root.join('config', 'alchemy', 'elements.yml'), "w") do |f|
        f.write config.to_yaml
      end

      puts "done.\n"
    end

    def find_gallery_pictures_rendering
      puts '5. Find element views that use gallery pictures:'

      erb_snippet = <<-ERB
    <%- element.nested_elements.available.each do |nested_element| -%>
      <%= render_element(nested_element) %>
    <%- end -%>
ERB
      erb_views = erb_element_partials(:view).select do |view|
        next if File.read(view).match(GALLERY_PICTURES_ERB_REGEXP).nil?
        inject_into_file view,
          "<%# TODO: Remove next block and render element.nested_elements instead %>\n",
          before: GALLERY_PICTURES_ERB_REGEXP
        true
      end

      haml_slim_snippet = <<-HAMLSLIM
    - element.nested_elements.available.each do |nested_element|
      = render_element(nested_element)
HAMLSLIM
      haml_views = haml_slim_element_partials(:view).select do |view|
        next if File.read(view).match(GALLERY_PICTURES_HAML_REGEXP).nil?
        inject_into_file view,
          "-# TODO: Remove next block and render element.nested_elements instead\n",
          before: GALLERY_PICTURES_HAML_REGEXP
        true
      end

      if erb_views.any?
        puts "- Found #{erb_views.length} ERB element views that render gallery pictures.\n"
        puts "  Please replace `element.contents.gallery_pictures` with:"
        puts erb_snippet
      elsif haml_views.any?
        puts "- Found #{haml_views.length} HAML/SLIM element views render gallery pictures.\n"
        puts "  Please replace `element.contents.gallery_pictures` with:"
        puts haml_slim_snippet
      else
        puts "- No element views found that render gallery pictures.\n"
      end
    end

    def remove_gallery_pictures_editor
      puts '6. Remove gallery pictures editor from your element editors:'

      (erb_element_partials(:editor) + haml_slim_element_partials(:editor)).each do |editor|
        next if File.read(editor).match(GALLERY_PICTURES_EDITOR_REGEXP).nil?
        gsub_file editor, GALLERY_PICTURES_EDITOR_REGEXP, ''
      end
    end

    def modify_old_element(element)
      nestable_element = "#{element['name']}_picture"
      element.delete('picture_gallery')
      element['nestable_elements'] ||= []
      element['nestable_elements'] << nestable_element
      element
    end

    def build_new_element(element)
      {
        'name' => "#{element['name']}_picture",
        'contents' => [{
          'name' => 'picture',
          'type' => 'EssencePicture'
        }]
      }
    end

    def erb_element_partials(kind)
      Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', "*_#{kind}.html.erb"))
    end

    def haml_slim_element_partials(kind)
      Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', "*_#{kind}.html.{haml,slim}"))
    end
  end
end
