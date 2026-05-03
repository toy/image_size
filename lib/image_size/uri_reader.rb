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

      def chunk_start(i)
        chunk_size * i
      end

      def chunk_range_header(i)
        { 'Range' => "bytes=#{chunk_start(i)}-#{chunk_start(i + 1) - 1}" }
      end
    end

    class BodyReader # :nodoc:
      include ChunkyReader

      attr_reader :byte_size

      def initialize(response)
        @body = String.new
        @body_reader = response.to_enum(:read_body)
        @byte_size = response.content_length
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

      attr_reader :byte_size

      def initialize(http, request_uri, chunk0, byte_size)
        @http = http
        @request_uri = request_uri
        @chunks = { 0 => chunk0 }
        @byte_size = byte_size
        @last_chunk = nil
      end

      def chunk(i)
        return if @byte_size && chunk_start(i) >= @byte_size
        return if @last_chunk && i > @last_chunk

        unless @chunks.key?(i)
          response = @http.get(@request_uri, chunk_range_header(i))
          case response
          when Net::HTTPPartialContent
            body = response.body
            @chunks[i] = body
            @last_chunk = i if body.length < chunk_size
          when Net::HTTPRequestedRangeNotSatisfiable
            @chunks[i] = nil
            @last_chunk = i if !@last_chunk || @last_chunk > i
          else
            fail "Unexpected response: #{response}"
          end
        end

        @chunks[i]
      end
    end

    class << self
      include HTTPChunkyReader

      def open(uri)
        http = nil
        (ImageSize.max_redirects + 1).times do
          ImageSize.uri_checker.call(uri)

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
            m = response['content-range'].match(%r{\bbytes\s+\d+-\d+/(\d+)}i) if response['content-range']
            byte_size = m[1].to_i if m
            return yield RangeReader.new(http, uri.request_uri, response.body, byte_size)
          when Net::HTTPRequestedRangeNotSatisfiable
            return yield StringReader.new('')
          else
            fail "Unexpected response: #{response}"
          end
        end

        fail "Too many redirects: #{uri}"
      ensure
        http.finish if http && http.started?
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

  # Maximum number of redirects
  def self.max_redirects
    @max_redirects || 5
  end

  # Set maximum number of redirects
  def self.max_redirects=(max_redirects)
    unless max_redirects.nil? || (max_redirects.is_a?(Integer) && max_redirects >= 0)
      fail ArgumentError, "max_redirects should be 0, a positive Integer or nil, got #{max_redirects}"
    end

    @max_redirects = max_redirects
  end

  # Hook to call before making every request
  def self.uri_checker
    @uri_checker || proc{ |_uri| }
  end

  # Set hook to call before making every request
  def self.uri_checker=(uri_checker)
    unless uri_checker.nil? || uri_checker.respond_to?(:call)
      fail ArgumentError, "uri_checker should respond to call or be nil, got #{uri_checker}"
    end

    @uri_checker = uri_checker
  end
end
