# frozen_string_literal: true

require 'image_size/reader'

class ImageSize
  class StringReader # :nodoc:
    include Reader

    def initialize(string)
      @string = if string.respond_to?(:encoding) && string.encoding.name != 'ASCII-8BIT'
        string.dup.force_encoding('ASCII-8BIT')
      else
        string
      end
    end

    def [](offset, length)
      @string[offset, length]
    end
  end
end
