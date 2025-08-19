require './servers/simple_server'
require './servers/fiber_server'
require './servers/async_server'
require './servers/thread_server'
# require './servers/polyphony_server'

app = Proc.new do
  sleep 1 # represent for time for waiting I/O 
  ['200', {'Content-Type' => 'text/html'}, ["Hello world! The time is #{Time.now}"]]
end

# Choose your server to test:
# SimpleServer.new(app).start      # Port 4000 - Synchronous
ThreadServer.new(app).start       # Port 4000 - Thread Pool
#AsyncServer.new(app).start        # Port 2000 - Async Gem
#FiberServer.new(app).start        # Port 4000 - Fiber with Async Scheduler
# PolyphonyServer.new(app).start     # Port 3000 - Polyphony Gem
