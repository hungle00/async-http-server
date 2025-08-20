require 'polyphony'
require 'net/http'
require 'uri'

class PolyphonyCrawler
  attr_reader :urls, :max_concurrent, :timeout, :results

  def initialize(urls: [], max_concurrent: 5, timeout: 3)
    @urls = urls
    @max_concurrent = max_concurrent
    @timeout = timeout
    @results = []
  end

  def crawl
    @urls.each_slice(@max_concurrent) do |batch|
      tasks = batch.map do |url|
        spin do
          crawl_single_url(url)
        end
      end
      batch_results = tasks.map(&:await)
      @results.concat(batch_results)
    end
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

  def crawl_single_url(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    data = response.body
    title = data.scan(/<title>([^<]+)<\/title>/).first&.first
    urls_found = data.scan(/<a href="([^"]+)"/)

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

crawler = PolyphonyCrawler.new(urls: urls, max_concurrent: 5, timeout: 3)
crawler.crawl
crawler.print_summary
