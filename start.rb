require './server'
require './fiber_server'

app = Proc.new do
  ['200', {'Content-Type' => 'text/html'}, ["Hello world! The time is #{Time.now}"]]
end

FiberServer.new(app).start
