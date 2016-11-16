require 'rspec'
require 'image_size'

describe ImageSize do
  (Dir['spec/images/*/*.*'] + [__FILE__]).each do |path|
    name = File.basename(path)
    match = /(\d+)x(\d+)\.([^.]+)$/.match(name)
    width, height, format = match[1].to_i, match[2].to_i, match[3].to_sym if match
    data = File.open(path, 'rb', &:read)

    it "gets format and dimensions of #{name} given as IO" do
      File.open(path, 'rb') do |fh|
        is = ImageSize.new(fh)
        expect([is.format, is.width, is.height]).to eq([format, width, height])
        expect(fh).not_to be_closed
        fh.rewind
        expect(fh.read).to eq(data)
      end
    end

    it "gets format and dimensions of #{name} given as StringIO" do
      io = StringIO.new(data)
      is = ImageSize.new(io)
      expect([is.format, is.width, is.height]).to eq([format, width, height])
      expect(io).not_to be_closed
      io.rewind
      expect(io.read).to eq(data)
    end

    it "gets format and dimensions of #{name} given as data" do
      is = ImageSize.new(data)
      expect([is.format, is.width, is.height]).to eq([format, width, height])
    end

    it "gets format and dimensions of #{name} given as Tempfile" do
      Tempfile.open(name) do |tf|
        tf.binmode
        tf.write(data)
        tf.rewind
        is = ImageSize.new(tf)
        expect([is.format, is.width, is.height]).to eq([format, width, height])
        expect(tf).not_to be_closed
        tf.rewind
        expect(tf.read).to eq(data)
      end
    end

    it "gets format and dimensions of #{name} given as IO when run twice" do
      File.open(path, 'rb') do |fh|
        is = ImageSize.new(fh)
        expect([is.format, is.width, is.height]).to eq([format, width, height])
        is = ImageSize.new(fh)
        expect([is.format, is.width, is.height]).to eq([format, width, height])
      end
    end

    it "gets format and dimensions of #{name} as path" do
      is = ImageSize.path(path)
      expect([is.format, is.width, is.height]).to eq([format, width, height])
    end
  end

  it "raises ArgumentError if argument is not valid" do
    expect {
      ImageSize.new(Object)
    }.to raise_error(ArgumentError)
  end

  {
    :png => "\211PNG\r\n\032\n",
    :jpeg => "\377\330",
  }.each do |type, data|
    it "raises FormatError if invalid #{type} given" do
      expect {
        ImageSize.new(data)
      }.to raise_error(ImageSize::FormatError)
    end
  end
end
