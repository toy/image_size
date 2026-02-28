# frozen_string_literal: true

require 'rspec'

require 'image_size/seekable_io_reader'

describe ImageSize::SeekableIOReader do
  context :[] do
    def new_io(&block)
      File.open('GPL', 'rb', &block)
    end

    def new_reader
      new_io do |io|
        yield ImageSize::SeekableIOReader.new(io)
      end
    end

    let(:content){ new_io(&:read) }

    it 'reads as expected when pieces are read consecutively' do
      new_reader do |reader|
        0.step(content.length + 4096, 100) do |offset|
          expect(reader[offset, 100]).to eq(content[offset, 100])
        end
      end
    end

    it 'reads as expected when pieces are read backwards' do
      new_reader do |reader|
        (content.length + 4096).step(0, -100) do |offset|
          expect(reader[offset, 100]).to eq(content[offset, 100])
        end
      end
    end

    it 'reads as expected when pieces are read in random order' do
      100.times do
        new_reader do |reader|
          0.step(content.length + 4096, 100).to_a.shuffle.each do |offset|
            expect(reader[offset, 100]).to eq(content[offset, 100])
          end
        end
      end
    end
  end
end
