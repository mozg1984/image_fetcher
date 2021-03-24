# frozen_string_literal: true

require "down"
require "fileutils"

class ImageFetcher
  class Error < StandardError; end

  attr_reader :source, :destination

  def initialize(options)
    @source = options[:file_path].to_s
    @destination = options[:directory_path].to_s
  end

  def fetch
    check_source!
    check_destination!
    image_url_list.each { |image_url| fetch_by(image_url) }
  end

  private

  def fetch_by(url)
    temp_image = Down.download(url)
    FileUtils.mv(temp_image.path, "#{destination}/#{temp_image.original_filename}")
  rescue Down::Error => err
    puts "An error occurred while downloading the file #{url}: #{err.message}"
  ensure
    temp_image&.close
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
