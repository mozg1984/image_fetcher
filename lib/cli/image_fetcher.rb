# frozen_string_literal: true

require 'down'
require 'fileutils'
require './lib/cli/settings_accessible'

module CLI
  class ImageFetcher
    include CLI::SettingsAccessible
    attr_reader :url, :destination

    def initialize(url, destination)
      @url = url.to_s
      @destination = destination.to_s
    end

    def fetch
      temp_image = Down.download(
        url,
        max_redirects: settings[:max_redirects],
        max_size: settings[:max_size]
      )

      FileUtils.mv(temp_image.path, "#{destination}/#{temp_image.original_filename}")
    rescue Down::Error => e
      puts "An error occurred while downloading the file #{url}: #{e.message}"
    ensure
      temp_image&.close
    end
  end
end
