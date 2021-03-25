# frozen_string_literal: true

require 'concurrent'
require './lib/cli/image_fetcher'
require './lib/cli/settings_accessible'

module CLI
  class App
    MIN_THREADS = 2

    class Error < StandardError; end

    include CLI::SettingsAccessible
    attr_reader :source, :destination

    def initialize(options)
      @source = options[:file_path].to_s
      @destination = options[:directory_path].to_s
    end

    def run
      check_source!
      check_destination!

      image_url_list.each do |image_url|
        fetch_image(image_url)
      end

      thread_pool.shutdown
      thread_pool.wait_for_termination
    end

    private

    def fetch_image(url)
      thread_pool.post do
        CLI::ImageFetcher.new(url, destination).fetch
      end
    end

    def image_url_list
      File.read(source).split
    end

    def check_source!
      return if File.file?(source)

      raise Error, "The given file #{source} does not exist"
    end

    def check_destination!
      return if File.directory?(destination)

      raise Error, "The given directory #{destination} does not exist"
    end

    def thread_pool
      @thread_pool ||= Concurrent::ThreadPoolExecutor.new(
        min_threads: [settings[:thread_pool][:min_threads].to_i, MIN_THREADS].max,
        max_threads: [settings[:thread_pool][:max_threads].to_i, Concurrent.processor_count].max,
        max_queue: 0
      )
    end
  end
end
