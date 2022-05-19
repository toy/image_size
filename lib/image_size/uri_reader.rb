# frozen_string_literal: true

require 'image_size/reader'
require 'image_size/chunky_reader'

require 'net/https'
require 'uri'

# This is a hacky experiment and not part of public API
#
# It adds ability to fetch size of image from http server while downloading only
# needed chunks if the server recognises Range header
class ImageSize
  class URIReader # :nodoc:
    include ChunkyReader

    def initialize(uri, redirects = 5)
      if !@http || @http.address != uri.host || @http.port != uri.port
        @http.finish if @http
        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = true if uri.scheme == 'https'
        @http.start
      end

      @request_uri = uri.request_uri
      response = request_chunk(0)

      case response
      when Net::HTTPRedirection
        raise "Too many redirects: #{response['location']}" unless redirects > 0

        initialize(uri + response['location'], redirects - 1)
      when Net::HTTPOK
        @body = response.body
      when Net::HTTPPartialContent
        @chunks = { 0 => response.body }
      when Net::HTTPRequestedRangeNotSatisfiable
        @body = ''
      else
        raise "Unexpected response: #{response}"
      end
    end

    def [](offset, length)
      if @body
        @body[offset, length]
      else
        super
      end
    end

    def chunk(i)
      unless @chunks.key?(i)
        response = request_chunk(i)
        case response
        when Net::HTTPPartialContent
          @chunks[i] = response.body
        else
          raise "Unexpected response: #{response}"
        end
      end

      @chunks[i]
    end

  private

    def request_chunk(i)
      @http.get(@request_uri, 'Range' => "bytes=#{chunk_size * i}-#{(chunk_size * (i + 1)) - 1}")
    end
  end

  module Reader # :nodoc:
    class << self
      def open_with_uri(input, &block)
        if input.is_a?(URI)
          yield URIReader.new(input)
        else
          open_without_uri(input, &block)
        end
      end
      alias_method :open_without_uri, :open
      alias_method :open, :open_with_uri
    end
  end

  def self.url(url)
    new(url.is_a?(URI) ? url : URI(url))
  end
end
