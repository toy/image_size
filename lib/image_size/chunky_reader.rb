# frozen_string_literal: true

require 'image_size/reader'

class ImageSize
  module ChunkyReader # :nodoc:
    include Reader

    # Size of a chunk in which to read
    def chunk_size
      4096
    end

    # Including class should define method chunk that accepts the chunk number
    # and returns a string of chunk_size length or shorter for last chunk, or
    # nil for further chunks.
    # Determines required chunks, takes parts of them to construct desired
    # substring, behaves same as str[start, length] except start can't be
    # negative.
    def [](offset, length)
      raise ArgumentError, "expected offset not to be negative, got #{offset}" if offset < 0
      return if length < 0

      first = offset / chunk_size
      return unless (first_chunk = chunk(first))

      last = (offset + length - 1) / chunk_size

      if first >= last
        first_chunk[offset - (first * chunk_size), length]
      else
        return unless (first_piece = first_chunk[offset - (first * chunk_size), chunk_size])

        chunks = (first.succ...last).map{ |i| chunk(i) }.unshift(first_piece)

        if (last_chunk = chunk(last))
          chunks.push(last_chunk[0, offset + length - (last * chunk_size)])
        end

        chunks.join
      end
    end
  end
end
