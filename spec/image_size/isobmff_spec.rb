# frozen_string_literal: true

require 'rspec'
require 'stringio'

require 'image_size/string_reader'
require 'image_size/isobmff'

describe ImageSize::ISOBMFF do
  boxes = Class.new do
    def self.build(&block)
      builder = new
      builder.instance_eval(&block)
      builder.string
    end

    def initialize
      @io = StringIO.new
    end

    def box(type, size, size64 = nil)
      @io << [size, type, size64].pack("Na4#{'Q>' if size64}")
      yield if block_given?
    end

    def data(content)
      @io << content
    end

    def string
      @io.string
    end
  end

  let(:instance){ described_class.new(options) }

  let(:string_reader){ ImageSize::StringReader.new(data) }

  describe '#walk' do
    let(:options){ {} }

    def is_expected
      expect{ |b| instance.walk(string_reader, &b) }
    end

    describe 'for multiple boxes' do
      let(:data) do
        boxes.build do
          box('abcd', 8 + 42){ data 'x' * 42 }
          box('efgh', 8 + 10)
        end
      end

      it do
        is_expected.to yield_successive_args(
          having_attributes(type: 'abcd', data_offset: 8, data_size: 42),
          having_attributes(type: 'efgh', data_offset: 58, data_size: 10)
        )
      end
    end

    describe 'for empty data' do
      let(:data){ '' }

      it{ is_expected.not_to yield_control }
    end

    describe 'for not enough data' do
      let(:data){ 'test' }

      it{ is_expected.to raise_error ImageSize::FormatError }
    end

    describe 'for a box without content' do
      let(:data){ boxes.build{ box('test', 8) } }

      it{ is_expected.to yield_successive_args(having_attributes(type: 'test', data_offset: 8, data_size: 0)) }
    end

    describe 'for a box with content' do
      let(:data){ boxes.build{ box('test', 8 + 42) } }

      it do
        is_expected.to yield_successive_args(having_attributes(type: 'test', data_offset: 8, data_size: 42))
      end
    end

    describe 'for not enough data in second box' do
      let(:data) do
        boxes.build do
          box('test', 8)
          data 'test'
        end
      end

      it{ is_expected.to yield_control.and raise_error ImageSize::FormatError }
    end

    describe 'for size-less box' do
      let(:data){ boxes.build{ box('test', 0) } }

      it do
        is_expected.to yield_successive_args(having_attributes(type: 'test', data_offset: 8, data_size: nil))
      end
    end

    (2..7).each do |size|
      describe "for wrong small box size #{size}" do
        let(:data){ boxes.build{ box('test', size) } }

        it{ is_expected.to raise_error ImageSize::FormatError }
      end
    end

    describe 'for a big box without content' do
      let(:data){ boxes.build{ box('test', 1, 16) } }

      it do
        is_expected.to yield_successive_args(having_attributes(type: 'test', data_offset: 16, data_size: 0))
      end
    end

    describe 'for a big box with content' do
      let(:data){ boxes.build{ box('test', 1, 16 + 42) } }

      it do
        is_expected.to yield_successive_args(having_attributes(type: 'test', data_offset: 16, data_size: 42))
      end
    end

    describe 'for a full box' do
      let(:options){ { full: %w[test] } }

      let(:data) do
        boxes.build do
          box('test', 8 + 42)
          data 'abcd'
        end
      end

      it do
        is_expected.to yield_successive_args(
          having_attributes(
            type: 'test',
            data_offset: 12,
            data_size: 38,
            version: 0x61,
            flags: 0x626364
          )
        )
      end
    end

    describe 'for a big full box' do
      let(:options){ { full: %w[test] } }

      let(:data) do
        boxes.build do
          box('test', 1, 16 + 42)
          data 'abcd'
        end
      end

      it do
        is_expected.to yield_successive_args(
          having_attributes(
            type: 'test',
            data_offset: 20,
            data_size: 38,
            version: 0x61,
            flags: 0x626364
          )
        )
      end
    end

    16.times do |size|
      describe "for wrong big box size #{size}" do
        let(:data){ boxes.build{ box('test', 1, size) } }

        it{ is_expected.to raise_error ImageSize::FormatError }
      end
    end

    context 'given offset' do
      let(:data) do
        boxes.build do
          box('test', 8)
          box('fooo', 8)
          box('barr', 8)
        end
      end

      def is_expected
        expect{ |b| instance.walk(string_reader, offset, &b) }
      end

      describe 'for offset at the end' do
        let(:offset){ 24 }

        it{ is_expected.not_to yield_control }
      end

      describe 'for offset at second box' do
        let(:offset){ 8 }

        it do
          is_expected.to yield_successive_args(
            having_attributes(type: 'fooo', data_offset: 16, data_size: 0),
            having_attributes(type: 'barr', data_offset: 24, data_size: 0)
          )
        end
      end
    end

    context 'given offset and length' do
      def is_expected
        expect{ |b| instance.walk(string_reader, offset, length, &b) }
      end

      describe 'for offset at second box' do
        let(:data) do
          boxes.build do
            box('test', 8)
            box('fooo', 8)
            box('barr', 8)
          end
        end
        let(:offset){ 8 }
        let(:length){ 8 }

        it do
          is_expected.to yield_successive_args(having_attributes(type: 'fooo', data_offset: 16, data_size: 0))
        end
      end
    end
  end

  describe '#recurse' do
    let(:data) do
      boxes.build do
        box('fooA', 8 + 8 + 2) do
          box('fooB', 8 + 2){ data '11' }
        end
        box('barA', 8 + 8 + 8 + 2) do
          box('barB', 8 + 8 + 2) do
            box('barC', 8 + 2) do
              data '22'
            end
          end
        end
        box('bazA', 8 + 8 + 2) do
          box('bazB', 8 + 2){ data '33' }
        end
      end
    end

    context 'when configured to recures all' do
      let(:options){ { recurse: %w[fooA barA barB bazA] } }

      it 'recurses complete tree' do
        enum = instance.to_enum(:recurse, string_reader)

        expect(enum.next).to have_attributes(type: 'fooA', data_offset: 8, data_size: 10)

        expect(enum.next).to have_attributes(type: 'fooB', data_offset: 16, data_size: 2)

        expect(enum.next).to have_attributes(type: 'barA', data_offset: 26, data_size: 18)

        expect(enum.next).to have_attributes(type: 'barB', data_offset: 34, data_size: 10)

        expect(enum.next).to have_attributes(type: 'barC', data_offset: 42, data_size: 2)

        expect(enum.next).to have_attributes(type: 'bazA', data_offset: 52, data_size: 10)

        expect(enum.next).to have_attributes(type: 'bazB', data_offset: 60, data_size: 2)

        expect{ enum.next }.to raise_exception(StopIteration)
      end

      it 'returns nil' do
        expect(instance.recurse(string_reader){ :foo }).to be_nil
      end
    end

    context 'when configured to recurse part' do
      let(:options){ { recurse: %w[barA] } }

      it 'recurses requested part' do
        enum = instance.to_enum(:recurse, string_reader)

        expect(enum.next).to have_attributes(type: 'fooA', data_offset: 8, data_size: 10)

        expect(enum.next).to have_attributes(type: 'barA', data_offset: 26, data_size: 18)

        expect(enum.next).to have_attributes(type: 'barB', data_offset: 34, data_size: 10)

        expect(enum.next).to have_attributes(type: 'bazA', data_offset: 52, data_size: 10)

        expect{ enum.next }.to raise_exception(StopIteration)
      end

      it 'returns nil' do
        expect(instance.recurse(string_reader){ :foo }).to be_nil
      end
    end

    context 'when configured to not recurse' do
      let(:options){ {} }

      it 'does not recurse' do
        enum = instance.to_enum(:recurse, string_reader)

        expect(enum.next).to have_attributes(type: 'fooA', data_offset: 8, data_size: 10)

        expect(enum.next).to have_attributes(type: 'barA', data_offset: 26, data_size: 18)

        expect(enum.next).to have_attributes(type: 'bazA', data_offset: 52, data_size: 10)

        expect{ enum.next }.to raise_exception(StopIteration)
      end

      it 'returns nil' do
        expect(instance.recurse(string_reader){ :foo }).to be_nil
      end
    end

    context 'when configured to stop' do
      let(:options){ { recurse: %w[fooA barA barB bazA], last: %w[barA] } }

      it 'recurses complete tree' do
        enum = instance.to_enum(:recurse, string_reader)

        expect(enum.next).to have_attributes(type: 'fooA', data_offset: 8, data_size: 10)

        expect(enum.next).to have_attributes(type: 'fooB', data_offset: 16, data_size: 2)

        expect(enum.next).to have_attributes(type: 'barA', data_offset: 26, data_size: 18)

        expect(enum.next).to have_attributes(type: 'barB', data_offset: 34, data_size: 10)

        expect(enum.next).to have_attributes(type: 'barC', data_offset: 42, data_size: 2)

        expect{ enum.next }.to raise_exception(StopIteration)
      end

      it 'returns nil' do
        expect(instance.recurse(string_reader){ :foo }).to be_nil
      end
    end
  end
end
