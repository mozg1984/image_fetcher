# frozen_string_literal: true

require 'cli/file_by_chunks_readable'

RSpec.describe CLI::FileByChunksReadable do
  let(:file) { 'spec/fixtures/files/image_links' }
  let(:file_content) { File.read(file) }

  subject(:file_by_chunks_readable_object) do
    Class.new { include CLI::FileByChunksReadable }.new
  end

  describe '#read_by_chunks' do
    context 'when chunk is larger than the string line' do
      it 'reads all content of file' do
        file_by_chunks_readable_object.read_by_chunks(file) do |buffer, _|
          expect(buffer).to eq(file_content)
        end
      end
    end

    context 'when chunk is smaller than the string line' do
      before do
        stub_const('CLI::FileByChunksReadable::CHUNK_SIZE', 16)
      end

      it 'reads file content by chunks' do
        file_by_chunks_readable_object.read_by_chunks(file) do |buffer, _|
          expect(buffer.split.length).to be < 2
        end
      end
    end
  end
end
