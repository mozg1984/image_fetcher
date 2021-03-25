# frozen_string_literal: true

require 'cli/image_fetcher'

RSpec.describe CLI::ImageFetcher do
  let(:url) { 'http://localhost/test.png' }
  let(:destination) { '.' }

  subject(:image_fetcher) { described_class.new(url, destination) }

  describe '#fetch' do
    let(:temp_file_mock) { spy(:temp_file) }

    before do
      allow(Down).to receive(:download).and_return(temp_file_mock)
      allow(FileUtils).to receive(:mv)
    end

    it 'calls Down downloader' do
      expect(Down).to receive(:download)
      image_fetcher.fetch
    end
  end
end
