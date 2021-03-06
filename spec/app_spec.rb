# frozen_string_literal: true

require 'cli/app'

RSpec.describe CLI::App do
  let(:file_path) { 'spec/fixtures/files/image_links' }
  let(:directory_path) { '.' }
  let(:options) { { file_path: file_path, directory_path: directory_path } }

  subject(:cli_app) { described_class.new(options) }

  describe '#run!' do
    context 'when options are not valid' do
      context 'when source file does not exist' do
        let(:file_path) { '' }

        it 'raises error' do
          expect { cli_app.run! }.to raise_error(described_class::FileNotFoundError)
        end
      end

      context 'when destination directory does not exist' do
        let(:directory_path) { 'test_directory' }

        it 'raises error' do
          expect { cli_app.run! }.to raise_error(described_class::DirectoryNotFoundError)
        end
      end
    end

    context 'when options are valid' do
      let(:thread_pool_mock) { spy('Concurrent::ThreadPoolExecutor') }

      before do
        allow(cli_app).to receive(:thread_pool).and_return(thread_pool_mock)
      end

      it 'posts tasks to the thread pool' do
        expect(thread_pool_mock).to receive(:post).exactly(10).times
        cli_app.run!
      end
    end
  end
end
