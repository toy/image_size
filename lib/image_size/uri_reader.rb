# frozen_string_literal: true

require 'image_size'
require 'image_size/reader'
require 'image_size/chunky_reader'

require 'net/https'
require 'uri'

# Experimental, not yet part of stable API
#
# It adds ability to fetch image meta from HTTP server while downloading only
# needed chunks if the server recognises Range header, otherwise fetches only
# required amount of data
class ImageSize
  module URIReader # :nodoc:
    module HTTPChunkyReader # :nodoc:
      include ChunkyReader

      def chunk_range_header(i)
        { 'Range' => "bytes=#{chunk_size * i}-#{(chunk_size * (i + 1)) - 1}" }
      end
    end

    class BodyReader # :nodoc:
      include ChunkyReader

      def initialize(response)
        @body = String.new
        @body_reader = response.to_enum(:read_body)
      end

      def [](offset, length)
        if @body_reader
          begin
            @body << @body_reader.next while @body.length < offset + length
          rescue StopIteration, IOError
            @body_reader = nil
          end
        end

        @body[offset, length]
      end
    end

    class RangeReader # :nodoc:
      include HTTPChunkyReader

      def initialize(http, request_uri, chunk0)
        @http = http
        @request_uri = request_uri
        @chunks = { 0 => chunk0 }
      end

      def chunk(i)
        unless @chunks.key?(i)
          response = @http.get(@request_uri, chunk_range_header(i))
          case response
          when Net::HTTPPartialContent
            @chunks[i] = response.body
          else
            raise "Unexpected response: #{response}"
          end
        end

        @chunks[i]
      end
    end

    class << self
      include HTTPChunkyReader

      def open(uri, max_redirects = 5)
        http = nil
        (max_redirects + 1).times do
          unless http && http.address == uri.host && http.port == uri.port
            http.finish if http

            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true if uri.scheme == 'https'
            http.start
          end

          response = http.request_get(uri.request_uri, chunk_range_header(0)) do |response_with_unread_body|
            case response_with_unread_body
            when Net::HTTPOK
              return yield BodyReader.new(response_with_unread_body)
            end
          end

          case response
          when Net::HTTPRedirection
            uri += response['location']
          when Net::HTTPPartialContent
            return yield RangeReader.new(http, uri.request_uri, response.body)
          when Net::HTTPRequestedRangeNotSatisfiable
            return yield StringReader.new('')
          else
            raise "Unexpected response: #{response}"
          end
        end

        raise "Too many redirects: #{uri}"
      ensure
        http.finish if http.started?
      end
    end
  end

  module Reader # :nodoc:
    class << self
      def open_with_uri(input, &block)
        if input.is_a?(URI)
          URIReader.open(input, &block)
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
