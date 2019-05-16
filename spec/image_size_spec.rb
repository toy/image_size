# frozen_string_literal: true

require 'rspec'
require 'image_size'
require 'tempfile'

describe ImageSize do
  (Dir['spec/images/*/*.*'] + [__FILE__]).each do |path|
    describe "for #{path}" do
      let(:name){ File.basename(path) }
      let(:attributes) do
        match = /(\d+)x(\d+)\.([^.]+)$/.match(name)
        width, height, format = match[1].to_i, match[2].to_i, match[3].to_sym if match
        size = format && [width, height]
        {
          :format => format,
          :width => width,
          :height => height,
          :w => width,
          :h => height,
          :size => size,
        }
      end
      let(:file_data){ File.open(path, 'rb', &:read) }

      context 'given as data' do
        it 'gets format and dimensions' do
          data = file_data.dup
          image_size = ImageSize.new(data)
          expect(image_size).to have_attributes(attributes)
          expect(data).to eq(file_data)
        end
      end

      context 'given as IO' do
        it 'gets format and dimensions' do
          File.open(path, 'rb') do |io|
            image_size = ImageSize.new(io)
            expect(image_size).to have_attributes(attributes)
            expect(io).not_to be_closed
            expect(io.pos).to_not be_zero
            io.rewind
            expect(io.read).to eq(file_data)
          end
        end
      end

      context 'given as StringIO' do
        it 'gets format and dimensions' do
          io = StringIO.new(file_data)
          image_size = ImageSize.new(io)
          expect(image_size).to have_attributes(attributes)
          expect(io).not_to be_closed
          expect(io.pos).to_not be_zero
          io.rewind
          expect(io.read).to eq(file_data)
        end
      end

      context 'given as Tempfile' do
        it 'gets format and dimensions' do
          Tempfile.open(name) do |io|
            io.binmode
            io.write(file_data)
            io.rewind
            image_size = ImageSize.new(io)
            expect(image_size).to have_attributes(attributes)
            expect(io).not_to be_closed
            expect(io.pos).to_not be_zero
            io.rewind
            expect(io.read).to eq(file_data)
          end
        end
      end

      context 'using path method' do
        it 'gets format and dimensions' do
          image_size = ImageSize.path(path)
          expect(image_size).to have_attributes(attributes)
        end
      end
    end
  end

  it 'raises ArgumentError if argument is not valid' do
    expect do
      ImageSize.new(Object)
    end.to raise_error(ArgumentError)
  end

  {
    :png => "\211PNG\r\n\032\n",
    :jpeg => "\377\330",
  }.each do |type, data|
    it "raises FormatError if invalid #{type} given" do
      expect do
        ImageSize.new(data)
      end.to raise_error(ImageSize::FormatError)
    end
  end
end
