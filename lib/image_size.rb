require 'stringio'

class ImageSize
  JpegCodeCheck = [
    "\xc0", "\xc1", "\xc2", "\xc3",
    "\xc5", "\xc6", "\xc7",
    "\xc9", "\xca", "\xcb",
    "\xcd", "\xce", "\xcf",
  ]

  attr_reader :format, :width, :height

  # receive image & make size
  # argument is image String, StringIO or IO
  def initialize(data)
    @data = data.dup
    @width  = nil
    @height = nil
    @format = nil

    if @data.is_a?(IO)
      img_top = @data.read(1024)
      img_io = def_read_o(@data)
    elsif @data.is_a?(StringIO)
      img_top = @data.read(1024)
      img_io = def_read_o(@data)
    elsif @data.is_a?(String)
      img_top = @data[0, 1024]
      img_io = StringIO.open(@data)
      img_io = def_read_o(img_io)
    else
      raise "argument class error!! #{data.class}"
    end

    if @format = check_format(img_top)
      @width, @height = self.send("measure_#{@format}", img_io)
    end

    if @data.is_a?(String)
      img_io.close
    end
  end

  # get image width and height as an array which to_s method returns "#{width}x#{height}"
  def size
    if format
      size = [width, height]
      def size.to_s
        join('x')
      end
      size
    end
  end

  alias :h :height
  alias :w :width

private

  def def_read_o(io)
    io.seek(0, 0)
    # define Singleton-method definition to IO (byte, offset)
    def io.read_o(length = 1, offset = nil)
      self.seek(offset, 0) if offset
      ret = self.read(length)
      raise 'cannot read!!' unless ret
      ret
    end
    io
  end

  def check_format(img_top)
    case
    when img_top =~ /^GIF8[7,9]a/                   then :gif
    when img_top[0, 8] == "\x89PNG\x0d\x0a\x1a\x0a" then :png
    when img_top[0, 2] == "\xFF\xD8"                then :jpeg
    when img_top[0, 2] == 'BM'                      then :bmp
    when img_top =~ /^P[1-7]/                       then :ppm
    when img_top =~ /\#define\s+\S+\s+\d+/          then :xbm
    when img_top[0, 4] == "MM\x00\x2a"              then :tiff
    when img_top[0, 4] == "II\x2a\x00"              then :tiff
    when img_top[0, 4] == "MM\x00\x2a"              then :tiff
    when img_top[0, 4] == "II\x2a\x00"              then :tiff
    when img_top =~ /\/\* XPM \*\//                 then :xpm
    when img_top[0, 4] == '8BPS'                    then :psd
    when img_top[1, 2] == 'WS'                      then :swf
    when img_top[0] == 10                           then :pcx
    end
  end

  def measure_gif(img_io)
    img_io.read_o(6)
    img_io.read_o(4).unpack('vv')
  end

  def measure_png(img_io)
    img_io.read_o(12)
    raise 'This file is not PNG.' unless img_io.read_o(4) == 'IHDR'
    img_io.read_o(8).unpack('NN')
  end

  def measure_jpeg(img_io)
    c_marker = "\xFF"   # Section marker.
    img_io.read_o(2)
    loop do
      marker, code, length = img_io.read_o(4).unpack('aan')
      raise 'JPEG marker not found!' if marker != c_marker

      if JpegCodeCheck.include?(code)
        height, width = img_io.read_o(5).unpack('xnn')
        return [width, height]
      end
      img_io.read_o(length - 2)
    end
  end

  def measure_bmp(img_io)
    img_io.read_o(26).unpack('x18VV');
  end

  def measure_ppm(img_io)
    header = img_io.read_o(1024)
    header.gsub!(/^\#[^\n\r]*/m, '')
    header =~ /^(P[1-6])\s+?(\d+)\s+?(\d+)/m
    case $1
      when 'P1', 'P4' then @format = :pbm
      when 'P2', 'P5' then @format = :pgm
    end

    [$2.to_i, $3.to_i]
  end

  alias :measure_pgm :measure_ppm
  alias :measure_pbm :measure_ppm

  def measure_xbm(img_io)
    img_io.read_o(1024) =~ /^\#define\s*\S*\s*(\d+)\s*\n\#define\s*\S*\s*(\d+)/mi

    [$1.to_i, $2.to_i]
  end

  def measure_xpm(img_io)
    width = height = nil
    while(line = img_io.read_o(1024))
      if line =~ /"\s*(\d+)\s+(\d+)(\s+\d+\s+\d+){1,2}\s*"/m
        width = $1.to_i; height = $2.to_i
        break
      end
    end

    [width, height]
  end

  def measure_psd(img_io)
    img_io.read_o(26).unpack('x14NN')
  end

  def measure_tiff(img_io)
    endian = (img_io.read_o(4) =~ /II\x2a\x00/o) ? 'v' : 'n' # 'v' little-endian   'n' default to big-endian

    packspec = [
      nil,           # nothing (shouldn't happen)
      'C',           # BYTE (8-bit unsigned integer)
      nil,           # ASCII
      endian,        # SHORT (16-bit unsigned integer)
      endian.upcase, # LONG (32-bit unsigned integer)
      nil,           # RATIONAL
      'c',           # SBYTE (8-bit signed integer)
      nil,           # UNDEFINED
      endian,        # SSHORT (16-bit unsigned integer)
      endian.upcase, # SLONG (32-bit unsigned integer)
    ]

    offset = img_io.read_o(4).unpack(endian.upcase)[0] # Get offset to IFD

    ifd = img_io.read_o(2, offset)
    num_dirent = ifd.unpack(endian)[0]                   # Make it useful
    offset += 2
    num_dirent = offset + (num_dirent * 12);             # Calc. maximum offset of IFD

    ifd = width = height = nil
    while(width.nil? || height.nil?)
      ifd = img_io.read_o(12, offset)                 # Get first directory entry
      break if (ifd.nil? || (offset > num_dirent))
      offset += 12
      tag = ifd.unpack(endian)[0]                       # ...and decode its tag
      type = ifd[2, 2].unpack(endian)[0]                # ...and the data type

      # Check the type for sanity.
      next if (type > packspec.size + 0) || (packspec[type].nil?)
      if tag == 0x0100                                  # Decode the value
        width = ifd[8, 4].unpack(packspec[type])[0]
      elsif tag == 0x0101                               # Decode the value
        height = ifd[8, 4].unpack(packspec[type])[0]
      end
    end

    [width, height]
  end

  def measure_pcx(img_io)
    header = img_io.read_o(128)
    head_part = header.unpack('C4S4')

    [head_part[6] - head_part[4] + 1, head_part[7] - head_part[5] + 1]
  end

  def measure_swf(img_io)
    header = img_io.read_o(9)

    sig1 = header[0, 1]
    sig2 = header[1, 1]
    sig3 = header[2, 1]

    unless ((sig1 == 'F' || sig1 == 'C') && sig2 == 'W' && sig3 == 'S')
      raise 'This file is not SWF.'
    end

    bit_length = Integer("0b#{header.unpack('@8B5')}")
    header << img_io.read_o(bit_length * 4 / 8 + 1)
    str = header.unpack("@8B#{5 + bit_length * 4}")[0]
    last = 5
    x_min = Integer("0b#{str[last, bit_length]}")
    x_max = Integer("0b#{str[(last += bit_length), bit_length]}")
    y_min = Integer("0b#{str[(last += bit_length), bit_length]}")
    y_max = Integer("0b#{str[(last += bit_length), bit_length]}")

    [(x_max - x_min) / 20, (y_max - y_min) / 20]
  end
end
