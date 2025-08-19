# Async Gem Example
puts "1. Async Gem Example:"
begin
  require 'async'
  require 'async/http/internet'
  Async do
    internet = Async::HTTP::Internet.new
    response = internet.get("https://httpbin.org/delay/1")
    puts "  Async Response: #{response.read}"
  ensure
    internet&.close
  end
rescue => e
  puts "  ❌ Async Error: #{e.message}"
end
puts

# Polyphony Example
puts "2. Polyphony Example:"
begin
  require 'polyphony'
  require 'net/http'
  require 'uri'

  response = spin do
    uri = URI("https://httpbin.org/delay/1")
    Net::HTTP.get_response(uri)
  end.await

  puts "  Polyphony Response: #{response.body}"
rescue => e
  puts "  ❌ Polyphony Error: #{e.message}"
end
