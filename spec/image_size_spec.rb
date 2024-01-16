# frozen_string_literal: true

require 'rspec'

require 'image_size'
require 'image_size/uri_reader'

require 'tempfile'
require 'shellwords'

require 'test_server'

RSpec.configure do |config|
  config.order = :random
end

describe ImageSize do
  before :all do
    @server = TestServer.new
  end

  after :all do
    @server.finish
  end

  def retry_on(exception_class)
    attempt = 1
    begin
      yield
    rescue exception_class => e
      warn "Attempt #{attempt}: #{e.inspect}"
      raise unless attempt < 3

      attempt += 1
      retry
    end
  end

  def supported_formats
    ImageSize.private_instance_methods.map{ |name| name[/\Asize_of_(.*)\z/, 1] }.compact.sort
  end

  describe 'README' do
    let(:readme){ File.read('README.markdown') }

    it 'lists all supported formats' do
      expect(readme[/^Formats: .*$/]).to eq("Formats: #{supported_formats.map{ |format| "`#{format}`" }.join(', ')}.")
    end
  end

  describe 'gemspec' do
    let(:gemspec){ Gem::Specification.load('image_size.gemspec') }

    it 'lists all supported formats in description' do
      expect(gemspec.description).to eq("Measure following file dimensions: #{supported_formats.join(', ')}")
    end
  end

  Dir['spec/**/*'].each do |path|
    next unless File.file?(path)

    describe "for #{path}" do
      let(:name){ File.basename(path) }
      let(:attributes) do
        if (match = /(\d+)x(\d+)\.([^.]+)$/.match(name))
          width = match[1].to_i
          height = match[2].to_i
          format = match[3].to_sym
        end
        size = format && [width, height]
        media_types = ImageSize::MEDIA_TYPES[format] || []
        media_type = format && media_types.first.to_s
        {
          format: format,
          width: width,
          height: height,
          w: width,
          h: height,
          size: size,
          media_type: media_type,
          media_types: media_types,
        }
      end
      let(:file_data){ File.binread(path) }
      let(:file_size){ file_data.length }

      before do
        max_file_size = 16_384

        if file_size > max_file_size
          raise "reduce resulting gem size, #{path} is too big (#{file_size} > #{max_file_size})"
        end
      end

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
            if file_size.zero?
              expect(io.pos).to be_zero
            else
              expect(io.pos).to_not be_zero
            end
            io.rewind
            expect(io.read).to eq(file_data)
          end
        end
      end

      context 'given as unseekable IO' do
        it 'gets format and dimensions' do
          IO.popen(%W[cat #{path}].shelljoin, 'rb') do |io|
            image_size = ImageSize.new(io)
            expect(image_size).to have_attributes(attributes)
            expect(io).not_to be_closed
          end
        end
      end

      context 'given as StringIO' do
        it 'gets format and dimensions' do
          io = StringIO.new(file_data)
          image_size = ImageSize.new(io)
          expect(image_size).to have_attributes(attributes)
          expect(io).not_to be_closed
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
            if file_size.zero?
              expect(io.pos).to be_zero
            else
              expect(io.pos).to_not be_zero
            end
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

      context 'fetching from webserver' do
        let(:file_url){ @server.base_url + path }

        context 'supporting range' do
          context 'without redirects' do
            it 'gets format and dimensions' do
              image_size = retry_on Timeout::Error do
                ImageSize.url(file_url)
              end
              expect(image_size).to have_attributes(attributes)
            end
          end

          context 'with redirects' do
            it 'gets format and dimensions' do
              image_size = retry_on Timeout::Error do
                ImageSize.url("#{file_url}?redirect=5")
              end
              expect(image_size).to have_attributes(attributes)
            end
          end

          context 'with too many redirects' do
            it 'gets format and dimensions' do
              expect do
                retry_on Timeout::Error do
                  ImageSize.url("#{file_url}?redirect=6")
                end
              end.to raise_error(/Too many redirects/)
            end
          end
        end

        context 'not supporting range' do
          context 'without redirects' do
            it 'gets format and dimensions' do
              image_size = retry_on Timeout::Error do
                ImageSize.url("#{file_url}?ignore_range")
              end
              expect(image_size).to have_attributes(attributes)
            end
          end

          context 'with redirects' do
            it 'gets format and dimensions' do
              image_size = retry_on Timeout::Error do
                ImageSize.url("#{file_url}?ignore_range&redirect=5")
              end
              expect(image_size).to have_attributes(attributes)
            end
          end

          context 'with too many redirects' do
            it 'gets format and dimensions' do
              expect do
                retry_on Timeout::Error do
                  ImageSize.url("#{file_url}?ignore_range&redirect=6")
                end
              end.to raise_error(/Too many redirects/)
            end
          end
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
    png: "\211PNG\r\n\032\n",
    jpeg: "\377\330",
  }.each do |type, data|
    it "raises FormatError if invalid #{type} given" do
      expect do
        ImageSize.new(data)
      end.to raise_error(ImageSize::FormatError)
    end
  end
end
