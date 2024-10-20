require 'socket'
require 'async/scheduler'
require './http_utils/request_parser'
require './http_utils/http_responder'

class FiberServer
  PORT = ENV.fetch('PORT', 3000)
  HOST = ENV.fetch('HOST', '127.0.0.1').freeze
  # number of incoming connections to keep in a buffer
  SOCKET_READ_BACKLOG = ENV.fetch('TCP_BACKLOG', 12).to_i

  attr_accessor :app

  def initialize(app)
    self.app = app
  end

  def start
    Fiber.set_scheduler(Async::Scheduler.new)
    socket = TCPServer.new(HOST, PORT)
    socket.listen(SOCKET_READ_BACKLOG)

    Fiber.schedule do
      loop do
        conn = socket.accept # wait for a client to connect
        Fiber.schedule do
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
end
