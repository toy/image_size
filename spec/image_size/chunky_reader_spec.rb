# frozen_string_literal: true

require 'rspec'

require 'image_size/chunky_reader'

describe ImageSize::ChunkyReader do
  context :[] do
    test_reader = Class.new do
      include ImageSize::ChunkyReader

      def initialize(string)
        @string = string
      end

    private

      def chunk(i)
        @string[i * chunk_size, chunk_size]
      end
    end

    custom_chunk_size_reader = Class.new(test_reader) do
      def chunk_size
        100
      end
    end

    {
      'empty string' => '',
      'a bit of data' => 'foo bar baz',
      'a lot of data' => File.binread('GPL'),
    }.each do |data_description, data|
      {
        'default' => test_reader.new(data),
        'custom' => custom_chunk_size_reader.new(data),
      }.each do |chunk_size_description, reader|
        context "for #{data_description} using reader with #{chunk_size_description} chunk size" do
          it 'raises ArgumentError for negative offset' do
            [-1, 0, 1, 100].each do |length|
              expect{ reader[-1, length] }.to raise_exception(ArgumentError)
            end
          end

          it 'behaves same as fetching a string for any offset and length' do
            full_chunks = data.length / reader.chunk_size
            offsets = [0, 1, full_chunks - 1, full_chunks, full_chunks + 1].map do |i|
              [-1, 0, 1].map do |add|
                (i * reader.chunk_size) + add
              end
            end.flatten

            offsets.each do |offset|
              next if offset < 0

              offsets.each do |offset_b|
                length = offset_b - offset
                expect(reader[offset, length]).to eq(data[offset, length]),
                                                  [
                                                    "for offset #{offset} and length #{length}",
                                                    "expected: #{data[offset, length].inspect}",
                                                    "     got: #{reader[offset, length].inspect}",
                                                  ].join("\n")
              end
            end
          end
        end
      end
    end
  end
end
