require 'socket'
require 'polyphony'
require_relative '../http_utils/request_parser'
require_relative '../http_utils/http_responder'

class PolyphonyServer
  PORT = ENV.fetch('PORT', 4000)
  HOST = ENV.fetch('HOST', '127.0.0.1').freeze

  attr_accessor :app

  def initialize(app)
    self.app = app
  end

  def start
    socket = TCPServer.new(HOST, PORT)
    puts "🚀 Polyphony Server starting on #{HOST}:#{PORT}"

    loop do
      conn = socket.accept # wait for a client to connect
      spin do
        request = RequestParser.call(conn)
        status, headers, body = app.call(request)
        puts status, headers, body
        HttpResponder.call(conn, status, headers, body)
      rescue => e
        puts e.message
      ensure
        conn&.close
      end
    end
  end
end
