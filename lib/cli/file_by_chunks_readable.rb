# frozen_string_literal: true

module CLI
  module FileByChunksReadable
    CHUNK_SIZE = 1024 # 1KB
    WHITESPACES = [' ', "\n"].freeze

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def read_by_chunks(path, &block)
        file = File.open(path, 'r')
        file_size = file.size
        start_pos = 0
        end_pos = CHUNK_SIZE

        loop do
          end_pos = file_size - 1 if end_pos >= file_size

          file.seek(end_pos)

          loop do
            break if WHITESPACES.include?(file.readchar) || file.eof

            end_pos += 1
          end

          file.seek(start_pos)
          buffer = file.readpartial(end_pos - start_pos + 1)

          start_pos = end_pos + 1
          end_pos = start_pos + CHUNK_SIZE
          eof = start_pos >= file_size

          block.call(buffer, eof)
          break if eof
        end
      rescue EOFError
        # Avoiding garbage in the STDOUT
      ensure
        file.close
      end
    end

    def read_by_chunks(file, &block)
      self.class.read_by_chunks(file, &block)
    end
  end
end
