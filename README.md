# HTTP Server

Build a simple Ruby HTTP Server from scratch using Fibers and Async gem.  

Based on https://github.com/TheRusskiy/ruby3-http-server  

About Async gem: https://socketry.github.io/async/index.html  

## Benchmarking
You can use `wrk` to send requests
```
wrk -t8 -c200 -d20s http://127.0.0.1:4000
``` 
For testing purpose, I suppose that each request needs 1s to finish
```rb
Proc.new do
  sleep 1 # represent for time for waiting I/O 
  ['200', {'Content-Type' => 'text/html'}, ["Hello world! The time is #{Time.now}"]]
end
```

**Single-thread server**
Because each request needs 1s to finish and the server can only 1 request per time, so the result:

``` 
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.01s     0.00us   1.01s   100.00%
    Req/Sec     0.05      0.22     1.00     95.00%
  20 requests in 20.09s, 2.56KB read
  Socket errors: connect 0, read 723, write 0, timeout 19
Requests/sec:      1.00
Transfer/sec:     130.41B
```
**Multi-thread server**
Use simple thread pool with max size is 5, or 5 thread per time
```
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.38s   510.13ms   2.00s    62.50%
    Req/Sec     0.62      2.34    19.00     97.10%
  96 requests in 20.08s, 12.28KB read
  Socket errors: connect 0, read 1081, write 0, timeout 88
Requests/sec:      4.78
Transfer/sec:     626.20B
```

**Async/Fibers server**
```
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.00s     2.11ms   1.01s    85.92%
    Req/Sec    40.79     38.68   232.00     83.61%
  3800 requests in 20.08s, 486.13KB read
  Socket errors: connect 0, read 1307, write 2, timeout 0
Requests/sec:    189.20
Transfer/sec:     24.20KB
```
