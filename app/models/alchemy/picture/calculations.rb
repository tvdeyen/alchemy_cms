# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    module Calculations
      # Returns true if picture's width is greater than it's height
      #
      def landscape_format?
        image_file.landscape?
      end
      alias_method :landscape?, :landscape_format?

      # Returns true if picture's width is smaller than it's height
      #
      def portrait_format?
        image_file.portrait?
      end
      alias_method :portrait?, :portrait_format?

      # Returns true if picture's width and height is equal
      #
      def square_format?
        image_file.aspect_ratio == 1.0
      end
      alias_method :square?, :square_format?

      # An Image smaller than dimensions
      # can not be cropped to given size - unless upsample is true.
      #
      def can_be_cropped_to?(string, upsample = false)
        return true if upsample

        is_bigger_than? sizes_from_string(string)
      end

      # Returns true if both dimensions of the base image are bigger than the dimensions hash.
      #
      def is_bigger_than?(dimensions)
        image_file_width > dimensions[:width] && image_file_height > dimensions[:height]
      end

      # Returns true is one dimension of the base image is smaller than the dimensions hash.
      #
      def is_smaller_than?(dimensions)
        !is_bigger_than?(dimensions)
      end

      # Given a string with an x, this function returns a Hash with point
      # :width and :height.
      #
      def sizes_from_string(string = "0x0")
        string = "0x0" if string.nil? || string.empty?

        raise ArgumentError unless string =~ /(\d*x\d*)/

        width, height = string.scan(/(\d*)x(\d*)/)[0].map(&:to_i)

        width = 0 if width.nil?
        height = 0 if height.nil?
        {
          width: width,
          height: height,
        }
      end

      # This function returns the :width and :height of the image file
      # as a Hash
      def image_size
        {
          width: image_file_width,
          height: image_file_height,
        }
      end
    end
  end
end
