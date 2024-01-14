# frozen_string_literal: true

require 'webrick'
require 'stringio'

class TestServer
  attr_reader :base_url

  def initialize(host = '127.0.0.1')
    server_options = {
      Logger: WEBrick::Log.new(StringIO.new),
      AccessLog: [],
      BindAddress: host,
      Port: 0, # get the next available port
      DocumentRoot: '.',
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

    @server = WEBrick::HTTPServer.new(server_options)
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
