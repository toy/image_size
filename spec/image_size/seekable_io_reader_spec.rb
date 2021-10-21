# frozen_string_literal: true

require 'rspec'

require 'image_size/seekable_io_reader'

describe ImageSize::SeekableIOReader do
  context :[] do
    def ios
      @ios ||= []
    end

    def io
      File.open('GPL', 'rb').tap do |io|
        ios << io
      end
    end

    after do
      ios.pop.close until ios.empty?
    end

    def new_reader
      ImageSize::SeekableIOReader.new(io)
    end

    let(:content){ io.read }

    it 'reads as expected when pieces are read consecutively' do
      reader = new_reader
      0.step(content.length + 4096, 100) do |offset|
        expect(reader[offset, 100]).to eq(content[offset, 100])
      end
    end

    it 'reads as expected when pieces are read backwards' do
      reader = new_reader
      (content.length + 4096).step(0, -100) do |offset|
        expect(reader[offset, 100]).to eq(content[offset, 100])
      end
    end

    it 'reads as expected when pieces are read in random order' do
      100.times do
        reader = new_reader
        0.step(content.length + 4096, 100).to_a.shuffle.each do |offset|
          expect(reader[offset, 100]).to eq(content[offset, 100])
        end
      end
    end
  end
end
