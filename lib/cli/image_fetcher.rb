# frozen_string_literal: true

require 'down'
require 'fileutils'
require 'securerandom'
require './lib/cli/settings_accessible'

module CLI
  class ImageFetcher
    CHUNK_SIZE = 1024 # 1KB

    class Error < StandardError; end

    class TooLargeImage < Error; end

    class UnknownContentType < Error; end

    include CLI::SettingsAccessible
    attr_reader :url, :destination

    def initialize(url, destination)
      @url = url.to_s
      @destination = destination.to_s
    end

    def fetch
      fetch!
    rescue ImageFetcher::Error, Down::Error, Errno::ENOENT, Errno::EACCES => e
      puts "An error occurred while downloading the file #{url}: #{e.message}"
    end

    def fetch!
      remote_image = Down.open(url, **settings[:down])

      check_size!(remote_image)
      check_content_type!(remote_image)

      image_file = File.new(local_filename_for(remote_image), 'wb')

      loop do
        break if remote_image.eof?

        image_file.write(remote_image.read(CHUNK_SIZE))
      end
    ensure
      remote_image&.close
      image_file&.close
    end

    private

    def local_filename_for(remote_image)
      extension = content_type(remote_image).split('/')[1]
      extension = ".#{extension}" unless extension.empty?
      "#{destination}/#{SecureRandom.urlsafe_base64}#{extension}"
    end

    def content_type(remote_image)
      @content_type ||= remote_image.data&.[](:headers)&.[]('Content-Type')&.to_s
    end

    def check_size!(remote_image)
      max_size = settings[:down][:max_size]
      return if remote_image.size <= max_size

      raise ImageFetcher::TooLargeImage, "file is too large (max is #{max_size / 1024 / 1024}MB)"
    end

    def check_content_type!(remote_image)
      return if settings[:down][:content_type].include?(content_type(remote_image))

      raise ImageFetcher::UnknownContentType, "file contains unknown content type #{content_type(remote_image)}"
    end
  end
end
