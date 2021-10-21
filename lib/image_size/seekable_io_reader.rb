# frozen_string_literal: true

require 'image_size/chunky_reader'

class ImageSize
  class SeekableIOReader # :nodoc:
    include ChunkyReader

    def initialize(io)
      @io = io
      @pos = 0
      @chunks = {}
    end

  private

    def chunk(i)
      unless @chunks.key?(i)
        @io.seek((chunk_size * i) - @pos, IO::SEEK_CUR)
        data = @io.read(chunk_size)
        @pos = chunk_size * i
        @pos += data.length if data
        @chunks[i] = data
      end

      @chunks[i]
    end
  end
end
