# frozen_string_literal: true

require './lib/cli/image_fetcher'

module CLI
  class App
    class Error < StandardError; end

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
    end

    private

    def fetch_image(url)
      CLI::ImageFetcher.new(url, destination).fetch
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
  end
end
