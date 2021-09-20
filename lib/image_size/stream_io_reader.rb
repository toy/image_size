# frozen_string_literal: true

require 'image_size/chunky_reader'

class ImageSize
  class StreamIOReader # :nodoc:
    include ChunkyReader

    def initialize(io)
      @io = io
      @chunks = []
    end

  private

    def chunk(i)
      @chunks << @io.read(chunk_size) while i >= @chunks.length && !@io.eof?

      @chunks[i]
    end
  end
end
