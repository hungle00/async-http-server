require 'socket'
require_relative '../http_utils/request_parser'
require_relative '../http_utils/http_responder'

class ThreadServer
  PORT = ENV.fetch('PORT', 4000)
  HOST = ENV.fetch('HOST', '127.0.0.1').freeze
  # number of incoming connections to keep in a buffer
  SOCKET_READ_BACKLOG = ENV.fetch('TCP_BACKLOG', 12).to_i

  attr_accessor :app

  def initialize(app)
    self.app = app
  end

  def start
    pool = ThreadPool.new(size: 5)
    socket = TCPServer.new(HOST, PORT)
    socket.listen(SOCKET_READ_BACKLOG)

    loop do
      conn = socket.accept # wait for a client to connect

      pool.schedule do
        begin
          request = RequestParser.call(conn)
          status, headers, body = app.call(request)
          puts status, headers
          HttpResponder.call(conn, status, headers, body)
        rescue => e
          puts e.message
        ensure
          conn&.close
        end
      end
    end
  ensure
    pool&.shutdown
  end
end

class ThreadPool
  def initialize(size:)
    @size = size
    @jobs = Queue.new
    @pool = Array.new(size) do
      Thread.new do
        catch(:exit) do
          loop do
            job, args = @jobs.pop
            job.call(*args)
          end
        end
      end
    end
  end

  def schedule(*args, &block)
    @jobs << [block, args]
  end

  def shutdown
    @size.times do
      schedule { throw :exit }
    end

    @pool.map(&:join)
  end
end
