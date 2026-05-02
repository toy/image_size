# frozen_string_literal: true

require 'webrick'
require 'stringio'

class TestServer
  class FileHandler < WEBrick::HTTPServlet::FileHandler
    def service(req, res)
      super
    rescue WEBrick::HTTPStatus::PartialContent
      if req.query['unknown_file_size']
        m = %r{\Abytes (\d+)-(\d+)/\d+\z}.match(res['content-range'])
        raise "Unexpected content-range: #{res['content-range']}" unless m

        res['content-range'] = "bytes #{m[1]}-#{m[2]}/*"

        # need to manually get the chunk, as webrick internally relies on content-range header with total size
        if res.body.is_a?(IO)
          offset = m[1].to_i
          size = m[2].to_i - offset + 1

          res.body.seek(offset, IO::SEEK_SET)
          res.body = res.body.read(size)
        end
      end

      raise
    end
  end

  attr_reader :base_url

  def initialize(host = '127.0.0.1')
    server_options = {
      AccessLog: [],
      BindAddress: host,
      Port: 0, # get the next available port
      RequestCallback: proc do |req, res|
        redirect = req.query['redirect'].to_i
        if redirect > 0
          res.set_redirect(
            WEBrick::HTTPStatus::TemporaryRedirect,
            [
              req.request_uri.port == @base_url.port ? @second_url : @base_url,
              req.request_uri.request_uri,
              "?#{encode_www_form(req.query.merge('redirect' => redirect - 1))}",
            ].inject(:+)
          )
        end

        req.header.delete('range') if req.query['ignore_range']
      end,
    }

    server_options[:Logger] = WEBrick::Log.new(StringIO.new) unless ENV['CI']

    @server = WEBrick::HTTPServer.new(server_options)
    @server.mount('/', FileHandler, '.')

    @server.listen(host, 0) # listen on second port

    @base_url = URI("http://#{host}:#{@server.listeners[0].addr[1]}/")
    @second_url = URI("http://#{host}:#{@server.listeners[1].addr[1]}/")

    @thread = Thread.new{ @server.start }
  end

  def finish
    @server.shutdown
    @thread.join
  end

private

  if URI.respond_to?(:encode_www_form)
    def encode_www_form(h)
      URI.encode_www_form(h)
    end
  else
    require 'cgi'

    def encode_www_form(h)
      h.map do |k, v|
        "#{CGI.escape(k)}=#{CGI.escape(v.to_s)}"
      end.join('&')
    end
  end
end
