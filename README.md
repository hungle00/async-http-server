# HTTP Server

Build a simple Ruby HTTP Server from scratch using Fibers and Async gem.  

Based on https://github.com/TheRusskiy/ruby3-http-server  

About Async gem: https://socketry.github.io/async/index.html  

# Testing
You can use `wrk` to send requests
```
wrk -t12 -c400 -d20s http://127.0.0.1:4000
``` 
