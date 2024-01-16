# encoding: BINARY
# frozen_string_literal: true

require 'image_size/isobmff'
require 'image_size/format_error'
require 'image_size/media_types'
require 'image_size/reader'
require 'image_size/seekable_io_reader'
require 'image_size/stream_io_reader'
require 'image_size/string_reader'

# Determine image format and size
class ImageSize
  # Array joining with 'x'
  class Size < Array
    # join using 'x'
    def to_s
      join('x')
    end

    # get first element
    def width
      self[0]
    end
    alias_method :w, :width

    # get second element
    def height
      self[1]
    end
    alias_method :h, :height
  end

  # Given path to image finds its format, width and height
  def self.path(path)
    new(Pathname.new(path))
  end

  # Used for svg
  def self.dpi
    @dpi || 72
  end

  # Used for svg
  def self.dpi=(dpi)
    @dpi = dpi.to_f
  end

  # Given image as any class responding to read and eof? or data as String, finds its format and dimensions
  def initialize(data)
    Reader.open(data) do |ir|
      @format = detect_format(ir)
      @width, @height = send("size_of_#{@format}", ir) if @format
    end
  end

  # Image format
  attr_reader :format

  # Image width
  attr_reader :width
  alias_method :w, :width

  # Image height
  attr_reader :height
  alias_method :h, :height

  # get image width and height as an array which to_s method returns "#{width}x#{height}"
  def size
    Size.new([width, height]) if format
  end

  # Media type (formerly known as a MIME type)
  def media_type
    MEDIA_TYPES.fetch(format, []).first
  end

  # All media types:
  # * commonly used and official like for apng and ico
  # * main and compatible like for heic and pnm (pbm, pgm, ppm)
  # * multiple unregistered like for mng
  def media_types
    MEDIA_TYPES.fetch(format, [])
  end

private

  SVG_R = /<svg\b([^>]*)>/.freeze
  XML_R = /<\?xml|<!--/.freeze
  def detect_format(ir)
    head = ir[0, 1024]
    case
    when head.nil? || head.empty?                                 then nil
    when head[0, 6] =~ /\AGIF8[79]a\z/                            then :gif
    when head[0, 8] == "\211PNG\r\n\032\n"                        then detect_png_type(ir)
    when head[0, 8] == "\212MNG\r\n\032\n"                        then :mng
    when head[0, 2] == "\377\330"                                 then :jpeg
    when head[0, 2] == 'BM'                                       then :bmp
    when head[0, 3] =~ /\AP([1-6]\s|7\n)\z/                       then detect_pnm_type(ir)
    when head =~ /\#define\s+\S+\s+\d+/                           then :xbm
    when %W[II*\0 MM\0*].include?(head[0, 4])                     then :tiff
    when head =~ %r{/\* XPM \*/}                                  then :xpm
    when head[0, 4] == '8BPS'                                     then :psd
    when head[0, 3] =~ /\A[FC]WS\z/                               then :swf
    when head =~ SVG_R || (head =~ XML_R && ir[0, 4096] =~ SVG_R) then :svg
    when head[0, 2] =~ /\n[\0-\5]/                                then :pcx
    when head[0, 12] =~ /\ARIFF(?m:....)WEBP\z/                   then :webp
    when head[0, 4] == "\0\0\1\0"                                 then :ico
    when head[0, 4] == "\0\0\2\0"                                 then :cur
    when head[0, 12] == "\0\0\0\fjP  \r\n\207\n"                  then detect_jpeg2000_type(ir)
    when head[0, 4] == "\377O\377Q"                               then :j2c
    when head[0, 4] == "\1\0\0\0" && head[40, 4] == ' EMF'        then :emf
    when head[4, 8] =~ /\Aftypavi[fs]\z/                          then :avif
    when head[4, 8] =~ /\Aftyp(hei[cs]|mif[12]|msf1)\z/           then :heic
    end
  end

  def detect_png_type(ir)
    offset = 8
    loop do
      type = ir[offset + 4, 4]
      break if ['IDAT', 'IEND', nil].include?(type)
      return :apng if type == 'acTL'

      length = ir.unpack1(offset, 4, 'N')
      offset += length + 8 + 4
    end
    :png
  end

  def detect_pnm_type(ir)
    case ir[0, 2]
    when 'P1', 'P4' then :pbm
    when 'P2', 'P5' then :pgm
    when 'P3', 'P6' then :ppm
    when 'P7'       then :pam
    end
  end

  def detect_jpeg2000_type(ir)
    return unless ir[16, 4] == 'ftyp'

    # using xl-box would be weird, but doesn't seem to contradict specification
    skip = ir[12, 4] == "\0\0\0\1" ? 16 : 8
    case ir[skip + 12, 4]
    when 'jp2 ' then :jp2
    when 'jpx ' then :jpx
    end
  end

  def size_of_gif(ir)
    ir.unpack(6, 4, 'vv')
  end

  def size_of_mng(ir)
    raise FormatError, 'MHDR not in place for MNG' unless ir[12, 4] == 'MHDR'

    ir.unpack(16, 8, 'NN')
  end

  def size_of_png(ir)
    raise FormatError, 'IHDR not in place for PNG' unless ir[12, 4] == 'IHDR'

    ir.unpack(16, 8, 'NN')
  end
  alias_method :size_of_apng, :size_of_png

  JPEG_CODE_CHECK = [
    0xC0, 0xC1, 0xC2, 0xC3,
    0xC5, 0xC6, 0xC7,
    0xC9, 0xCA, 0xCB,
    0xCD, 0xCE, 0xCF
  ].freeze
  def size_of_jpeg(ir)
    section_marker = "\xFF"
    offset = 2
    loop do
      offset += 1 until [nil, section_marker].include? ir[offset, 1]
      offset += 1 until section_marker != ir[offset + 1, 1]
      raise FormatError, 'EOF in JPEG' unless ir[offset, 1]

      code, length = ir.unpack(offset, 4, 'xCn')
      offset += 4

      return ir.unpack(offset + 1, 4, 'nn').reverse if JPEG_CODE_CHECK.include?(code)

      offset += length - 2
    end
  end

  def size_of_bmp(ir)
    header_size = ir.unpack1(14, 4, 'V')
    if header_size == 12
      ir.unpack(18, 4, 'vv')
    else
      ir.unpack(18, 8, 'VV').map do |n|
        if n > 0x7fff_ffff
          0x1_0000_0000 - n # absolute value of converted to signed
        else
          n
        end
      end
    end
  end

  def size_of_ppm(ir)
    header = ir[0, 1024]
    header.gsub!(/^\#[^\n\r]*/m, '')
    header =~ /^(P[1-6])\s+?(\d+)\s+?(\d+)/m
    [$2.to_i, $3.to_i]
  end
  alias_method :size_of_pbm, :size_of_ppm
  alias_method :size_of_pgm, :size_of_ppm

  def size_of_pam(ir)
    width = height = nil
    offset = 3
    until width && height
      if ir[offset, 1] == '#'
        offset += 1 until ["\n", '', nil].include?(ir[offset, 1])
        offset += 1
      else
        chunk = ir[offset, 32]
        case chunk
        when /\AWIDTH (\d+)\n/
          width = $1.to_i
        when /\AHEIGHT (\d+)\n/
          height = $1.to_i
        when /\AENDHDR\n/
          break
        when /\A(?:DEPTH|MAXVAL) \d+\n/, /\ATUPLTYPE \S+\n/
          # ignore
        else
          raise FormatError, "Unexpected data in PAM header: #{chunk.inspect}"
        end
        offset += $&.length
      end
    end
    [width, height]
  end

  def size_of_xbm(ir)
    ir[0, 1024] =~ /^\#define\s*\S*\s*(\d+)\s*\n\#define\s*\S*\s*(\d+)/mi
    [$1.to_i, $2.to_i]
  end

  def size_of_xpm(ir)
    length = 1024
    until (data = ir[0, length]) =~ /"\s*(\d+)\s+(\d+)(\s+\d+\s+\d+){1,2}\s*"/m
      raise FormatError, 'XPM size not found' if data.length != length

      length += 1024
    end
    [$1.to_i, $2.to_i]
  end

  def size_of_psd(ir)
    ir.unpack(14, 8, 'NN').reverse
  end

  def size_of_tiff(ir)
    endian2b = ir.fetch(0, 4) == "II*\000" ? 'v' : 'n'
    endian4b = endian2b.upcase
    packspec = [nil, 'C', nil, endian2b, endian4b, nil, 'c', nil, endian2b, endian4b]

    offset = ir.unpack1(4, 4, endian4b)
    num_dirent = ir.unpack1(offset, 2, endian2b)
    offset += 2
    num_dirent = offset + (num_dirent * 12)

    width = height = nil
    until width && height
      ifd = ir.fetch(offset, 12)
      raise FormatError, 'Reached end of directory entries in TIFF' if offset > num_dirent

      tag, type = ifd.unpack(endian2b * 2)
      offset += 12

      next unless packspec[type]

      value = ifd[8, 4].unpack(packspec[type])[0]
      case tag
      when 0x0100
        width = value
      when 0x0101
        height = value
      end
    end
    [width, height]
  end

  def size_of_pcx(ir)
    parts = ir.unpack(4, 8, 'v4')
    [parts[2] - parts[0] + 1, parts[3] - parts[1] + 1]
  end

  def size_of_swf(ir)
    value_bit_length = ir.unpack1(8, 1, 'B5').to_i(2)
    bit_length = (value_bit_length * 4) + 5
    rect_bits = ir.unpack1(8, (bit_length / 8) + 1, "B#{bit_length}")
    values = rect_bits[5..-1].unpack("a#{value_bit_length}" * 4).map{ |bits| bits.to_i(2) }
    x_min, x_max, y_min, y_max = values
    [(x_max - x_min) / 20, (y_max - y_min) / 20]
  end

  def size_of_svg(ir)
    attributes = {}
    svg_tag = ir[0, 1024][SVG_R, 1] || ir[0, 4096][SVG_R, 1]
    svg_tag.scan(/(\S+)=(?:'([^']*)'|"([^"]*)"|([^'"\s]*))/) do |name, v0, v1, v2|
      attributes[name] = v0 || v1 || v2
    end
    dpi = self.class.dpi
    [attributes['width'], attributes['height']].map do |length|
      next unless length

      pixels = case length.downcase.strip[/(?:em|ex|px|in|cm|mm|pt|pc|%)\z/]
      when 'em', 'ex', '%' then nil
      when 'in' then length.to_f * dpi
      when 'cm' then length.to_f * dpi / 2.54
      when 'mm' then length.to_f * dpi / 25.4
      when 'pt' then length.to_f * dpi / 72
      when 'pc' then length.to_f * dpi / 6
      else length.to_f
      end
      pixels.round if pixels
    end
  end

  def size_of_ico(ir)
    ir.unpack(6, 2, 'CC').map{ |v| v.zero? ? 256 : v }
  end
  alias_method :size_of_cur, :size_of_ico

  def size_of_webp(ir)
    case ir.fetch(12, 4)
    when 'VP8 '
      ir.unpack(26, 4, 'vv').map{ |v| v & 0x3fff }
    when 'VP8L'
      n = ir.unpack1(21, 4, 'V')
      [(n & 0x3fff) + 1, ((n >> 14) & 0x3fff) + 1]
    when 'VP8X'
      w16, w8, h16, h8 = ir.unpack(24, 6, 'vCvC')
      [(w16 | (w8 << 16)) + 1, (h16 | (h8 << 16)) + 1]
    end
  end

  JP2_WALKER = ImageSize::ISOBMFF.new(
    recurse: %w[jp2h],
    last: %w[jp2h]
  )
  def size_of_jp2(ir)
    JP2_WALKER.recurse(ir) do |box|
      return ir.unpack(box.data_offset, 8, 'NN').reverse if box.type == 'ihdr'
    end
  end
  alias_method :size_of_jpx, :size_of_jp2

  def size_of_j2c(ir)
    ir.unpack(8, 8, 'NN')
  end

  EMF_UMAX = 256**4
  EMF_SMAX = EMF_UMAX / 2

  def size_of_emf(ir)
    left, top, right, bottom =
      if RUBY_VERSION < '1.9'
        ir.unpack(24, 16, 'V*').map{ |u| u < EMF_SMAX ? u : u - EMF_UMAX }
      else
        ir.unpack(24, 16, 'L<*')
      end
    dpi = self.class.dpi
    [right - left + 1, bottom - top + 1].map do |n|
      (n.to_f * dpi / 2540).round
    end
  end

  HEIF_WALKER = ImageSize::ISOBMFF.new(
    recurse: %w[meta iprp ipco],
    full: %w[meta hdlr pitm ipma ispe],
    last: %w[meta]
  )
  def size_of_heif(ir)
    pitm = nil
    ipma = nil
    ispes = {}
    claps = {}
    irots = {}

    HEIF_WALKER.recurse(ir) do |box, _path|
      case box.type
      when 'hdlr'
        raise FormatError, "hdlr box too small (#{box.data_size})" if box.data_size < 8

        return nil unless ir[box.data_offset + 4, 4] == 'pict'
      when 'pitm'
        raise FormatError, 'second pitm box encountered' if pitm

        pitm = box.version == 0 ? ir.unpack1(box.data_offset, 2, 'n') : ir.unpack1(box.data_offset, 4, 'N')
      when 'ipma'
        stream = ir.stream(box.data_offset)

        property_index_16b = (box.flags & 1) == 1

        ipma ||= {}
        stream.unpack1(4, 'N').times do
          item_id = box.version == 0 ? stream.unpack1(2, 'n') : stream.unpack1(4, 'N')
          ipma[item_id] ||= Array.new(stream.unpack1(1, 'C')) do
            property_index_16b ? stream.unpack1(2, 'n') & 0x7fff : stream.unpack1(1, 'C') & 0x7f
          end
        end
      when 'ispe'
        ispes[box.index] ||= ir.unpack(box.data_offset, 8, 'NN')
      when 'clap'
        width_n, width_d, height_n, height_d = ir.unpack(box.data_offset, 16, 'N4')
        claps[box.index] ||= [Rational(width_n, width_d).round, Rational(height_n, height_d).round]
      when 'irot'
        irots[box.index] ||= ir.unpack1(box.data_offset, 1, 'C') & 0b11
      end
    end

    return unless ipma

    properties = ipma[pitm || ipma.keys.min]
    return unless properties

    dimensions = claps.values_at(*properties).compact.first || ispes.values_at(*properties).compact.first
    return unless dimensions

    irot = irots.values_at(*properties).compact.first
    if irot && irot.odd?
      dimensions.reverse
    else
      dimensions
    end
  end
  alias_method :size_of_avif, :size_of_heif
  alias_method :size_of_heic, :size_of_heif
end
