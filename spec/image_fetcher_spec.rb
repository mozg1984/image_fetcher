# frozen_string_literal: true

require 'image_fetcher'

RSpec.describe ImageFetcher do
  let(:options) { {} }

  subject(:image_fetcher) { described_class.new(options) }

  describe '#fetch' do
    context 'when options are not valid' do
      it 'raises error' do
        expect { image_fetcher.fetch }.to raise_error(described_class::Error)
      end
    end

    context 'when options are valid' do
      let(:file_path) { 'spec/fixtures/files/image_links' }
      let(:directory_path) { '.' }
      let(:options) { { file_path: file_path, directory_path: directory_path } }
      let(:temp_file_mock) { spy(:file) }

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
end
