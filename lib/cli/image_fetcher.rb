# frozen_string_literal: true

require 'down'
require 'fileutils'

module CLI
  class ImageFetcher
    attr_reader :url, :destination

    def initialize(url, destination)
      @url = url.to_s
      @destination = destination.to_s
    end

    def fetch
      temp_image = Down.download(url)
      FileUtils.mv(temp_image.path, "#{destination}/#{temp_image.original_filename}")
    rescue Down::Error => e
      puts "An error occurred while downloading the file #{url}: #{e.message}"
    ensure
      temp_image&.close
    end
  end
end
