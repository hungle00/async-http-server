require './simple_server'
require './fiber_server'
require './async_server'
require './thread_server'

app = Proc.new do
  sleep 1 # represent for time for waiting I/O 
  ['200', {'Content-Type' => 'text/html'}, ["Hello world! The time is #{Time.now}"]]
end

# SimpleServer.new(app).start
ThreadServer.new(app).start
# AsyncServer.new(app).start