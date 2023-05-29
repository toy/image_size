# frozen_string_literal: true

require 'pathname'
require 'stringio'

class ImageSize
  module Reader # :nodoc:
    class Stream # :nodoc:
      def initialize(reader, offset)
        @reader = reader
        @offset = offset
      end

      def unpack1(length, format)
        result = @reader.unpack1(@offset, length, format)
        @offset += length
        result
      end
    end

    class << self
      def open(input)
        case
        when input.is_a?(String)
          yield StringReader.new(input)
        when input.is_a?(StringIO)
          yield StringReader.new(input.string)
        when input.respond_to?(:read) && input.respond_to?(:eof?)
          yield for_io(input)
        when input.is_a?(Pathname)
          input.open('rb'){ |f| yield for_io(f) }
        else
          raise ArgumentError, "expected data as String or an object responding to read and eof?, got #{input.class}"
        end
      end

    private

      def for_io(io)
        if io.respond_to?(:stat) && !io.stat.file?
          StreamIOReader.new(io)
        else
          begin
            io.seek(0, IO::SEEK_CUR)
            SeekableIOReader.new(io)
          rescue Errno::ESPIPE, Errno::EINVAL
            StreamIOReader.new(io)
          end
        end
      end
    end

    def fetch(offset, length)
      chunk = self[offset, length]

      unless chunk && chunk.length == length
        raise FormatError, "Expected #{length} bytes at offset #{offset}, got #{chunk.inspect}"
      end

      chunk
    end

    def unpack(offset, length, format)
      fetch(offset, length).unpack(format)
    end

    if ''.respond_to?(:unpack1)
      def unpack1(offset, length, format)
        fetch(offset, length).unpack1(format)
      end
    else
      def unpack1(offset, length, format)
        fetch(offset, length).unpack(format)[0]
      end
    end

    def stream(offset)
      Stream.new(self, offset)
    end
  end
end
