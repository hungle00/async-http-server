require "async"
require "async/http/internet"
require "async/semaphore"

class WebCrawler
  attr_reader :urls, :max_concurrent, :timeout, :results

  def initialize(urls: [], max_concurrent: 5, timeout: 3)
    @urls = urls
    @max_concurrent = max_concurrent
    @timeout = timeout
    @results = []
  end

  def crawl
    Async do |task|
      internet = Async::HTTP::Internet.new
      semaphore = Async::Semaphore.new(@max_concurrent)

      # Create tasks for each URL and wait for all to complete
      tasks = @urls.map do |url|
        Async do
          semaphore.acquire do
            task.with_timeout(@timeout) do
              crawl_single_url(internet, url)
            end
          end
        end
      end

      # Wait for all tasks to complete
      @results = tasks.map(&:wait)

    rescue => e
      puts "Fatal error: #{e.message}"
      puts e.backtrace
    ensure
      internet&.close
    end

    @results
  end

  def print_summary
    puts "\n#### RESULTS SUMMARY ####"
    puts "Total URLs processed: #{@results.length}"

    puts "\n#### TITLES ####"
    puts @results.map { |r| r[:title] }

    puts "\n#### ALL UNIQUE URLS ####"
    puts @results.map { |r| r[:urls_found] }.flatten.uniq
  end

  private

  def crawl_single_url(internet, url)
    response = internet.get(URI.parse(url)).read
    title = response.scan(/<title>([^<]+)<\/title>/).first&.first
    urls_found = response.scan(/<a href="([^"]+)"/)

    puts "Completed: #{url} - Title: #{title&.[](0..50)}..."

    {
      url: url,
      title: title,
      urls_found: urls_found
    }
  end
end

urls = [
  "https://forum.rubyonrails.pl/",
  "https://forum.rubyonrails.pl/t/jak-zaczac-przygode-z-ruby-on-rails/18"
]

crawler = WebCrawler.new(urls: urls, max_concurrent: 5, timeout: 3)
crawler.crawl
crawler.print_summary
