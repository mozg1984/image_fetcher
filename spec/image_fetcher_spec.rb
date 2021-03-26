# frozen_string_literal: true

require 'cli/image_fetcher'

RSpec.describe CLI::ImageFetcher do
  let(:url) { 'http://localhost/test.png' }
  let(:destination) { '.' }
  let(:size) { 1 * 1024 * 1024 }
  let(:content_type) { 'image/png' }
  let(:data) { { headers: { 'Content-Type' => content_type } } }
  let(:remote_image_file_mock) { spy('Down::ChunkedIO') }
  let(:image_file_mock) { spy('File') }
  let(:image_file_content_mock) { 'Some binary image data' }

  subject(:image_fetcher) { described_class.new(url, destination) }

  def stub_transfering_data
    allow(Down).to receive(:open).and_return(remote_image_file_mock)
    allow(File).to receive(:new).and_return(image_file_mock)
    allow(remote_image_file_mock).to receive(:size).and_return(size)
    allow(remote_image_file_mock).to receive(:data).and_return(data)
    allow(remote_image_file_mock).to receive(:read).and_return(image_file_content_mock)
    allow(remote_image_file_mock).to receive(:eof?).and_return(false, true)
  end

  describe '#fetch' do
    context 'when url is empty' do
      let(:url) { '' }

      it 'does not raise any error' do
        expect { image_fetcher.fetch }.not_to raise_error
      end
    end

    context 'when url is incorrect' do
      let(:url) { 'oops://oops' }

      it 'does not raise any error' do
        expect { image_fetcher.fetch }.not_to raise_error
      end
    end

    context 'when url is correct' do
      before { stub_transfering_data }

      context 'when size is too large' do
        let(:size) { 10 * 1024 * 1024 }

        before { allow(remote_image_file_mock).to receive(:size).and_return(size) }

        it 'does not raise any error' do
          expect { image_fetcher.fetch }.not_to raise_error
        end
      end

      context 'when content_type is missing' do
        let(:data) { { headers: {} } }

        it 'does not raise any error' do
          expect { image_fetcher.fetch }.not_to raise_error
        end
      end

      context 'when content_type is unknown' do
        let(:content_type) { 'image/unknown' }

        it 'does not raise any error' do
          expect { image_fetcher.fetch }.not_to raise_error
        end
      end

      it 'delegates call to unsafe fetching' do
        expect(image_fetcher).to receive(:fetch!)
        image_fetcher.fetch
      end
    end
  end

  describe '#fetch!' do
    context 'when url is empty' do
      let(:url) { '' }

      it 'raises Down::Error error' do
        expect { image_fetcher.fetch! }.to raise_error(Down::Error)
      end
    end

    context 'when url is incorrect' do
      let(:url) { 'oops://oops' }

      it 'raises Down::Error error' do
        expect { image_fetcher.fetch! }.to raise_error(Down::Error)
      end
    end

    context 'when url is correct' do
      before { stub_transfering_data }

      context 'when size is too large' do
        let(:size) { 10 * 1024 * 1024 }

        before { allow(remote_image_file_mock).to receive(:size).and_return(size) }

        it 'raises TooLargeImage error' do
          expect { image_fetcher.fetch! }.to raise_error(described_class::TooLargeImage)
        end
      end

      context 'when content_type is missing' do
        let(:data) { { headers: {} } }

        it 'raises UnknownContentType error' do
          expect { image_fetcher.fetch! }.to raise_error(described_class::UnknownContentType)
        end
      end

      context 'when content_type is unknown' do
        let(:content_type) { 'image/unknown' }

        it 'raises UnknownContentType error' do
          expect { image_fetcher.fetch! }.to raise_error(described_class::UnknownContentType)
        end
      end

      it 'transfers binary data by chunks' do
        expect(remote_image_file_mock).to receive(:read).with(described_class::CHUNK_SIZE)
        expect(image_file_mock).to receive(:write).with(image_file_content_mock)
        image_fetcher.fetch!
      end
    end
  end
end
