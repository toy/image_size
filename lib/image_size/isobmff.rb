# frozen_string_literal: true

require 'image_size/format_error'

require 'set'

class ImageSize
  class ISOBMFF # :nodoc:
    class Box # :nodoc:
      attr_reader :type, :offset, :size, :relative_data_offset, :index

      def initialize(attributes)
        @type = attributes.fetch(:type)
        @offset = attributes.fetch(:offset)
        @size = attributes.fetch(:size) == 0 ? nil : attributes[:size]
        @relative_data_offset = attributes.fetch(:relative_data_offset)
        @index = attributes.fetch(:index)
      end

      def data_offset
        offset + relative_data_offset
      end

      def data_size
        size ? size - relative_data_offset : nil
      end
    end

    class FullBox < Box # :nodoc:
      attr_reader :version, :flags

      def initialize(attributes)
        super
        @version = attributes.fetch(:version)
        @flags = attributes.fetch(:flags)
      end
    end

    S64_OVERFLOW = 1 << 63

    def initialize(options = {})
      @full = options.fetch(:full, []).to_set
      @last = options.fetch(:last, []).to_set
      @recurse = options.fetch(:recurse, []).to_set
    end

    def walk(reader, offset = 0, length = nil)
      max_offset = length ? offset + length : S64_OVERFLOW
      index = 1
      while offset < max_offset && !['', nil].include?(reader[offset, 4])
        size = reader.unpack1(offset, 4, 'N')
        type = reader.fetch(offset + 4, 4)
        relative_data_offset = 8

        case size
        when 1
          size = reader.unpack1(offset + 8, 8, 'Q>')
          relative_data_offset += 8
          raise FormatError, "Unexpected ISOBMFF xl-box size #{size}" if size < 16
        when 2..7
          raise FormatError, "Reserved ISOBMFF box size #{size}"
        end

        attributes = {
          type: type,
          offset: offset,
          size: size,
          relative_data_offset: relative_data_offset,
          index: index,
        }

        if @full.include?(type)
          version_n_flags = reader.unpack1(offset + relative_data_offset, 4, 'N')
          attributes[:version] = version_n_flags >> 24
          attributes[:flags] = version_n_flags & 0xffffff

          attributes[:relative_data_offset] += 4

          yield FullBox.new(attributes)
        else
          yield Box.new(attributes)
        end

        break if size == 0 || @last.include?(type)

        index += 1
        offset += size
      end
    end

    def recurse(reader, offset = 0, length = nil, &block)
      walk(reader, offset, length) do |box|
        yield box

        recurse(reader, box.data_offset, box.data_size, &block) if @recurse.include?(box.type)
      end
    end
  end
end
