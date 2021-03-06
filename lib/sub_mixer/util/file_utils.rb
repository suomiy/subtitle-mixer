require 'charlock_holmes'

module SubMixer
  module FileUtils
    class << self
      BOM_LIST_HEX = {
          Encoding::UTF_8 => "\xEF\xBB\xBF", #"\uEFBBBF"
          Encoding::UTF_16BE => "\xFE\xFF", #"\uFEFF",
          Encoding::UTF_16LE => "\xFF\xFE",
          Encoding::UTF_32BE => "\x00\x00\xFE\xFF",
          Encoding::UTF_32LE => "\xFE\xFF\x00\x00",
      }

      def read(filename)
        begin
          File.read(filename)
        rescue
          raise "Could not open #{filename}"
        end
      end

      def write(content, filename)
        begin
          File.open(filename, 'w:UTF-8') do |f|
            f.write content
          end
          filename
        rescue
          raise "Could not write to file #{filename}"
        end
      end

      def as_safe_string(content, name, encoding=nil)
        begin
          unless encoding
            detection = CharlockHolmes::EncodingDetector.detect(content)
            encoding = detection[:encoding]
          end
          SubMixer.logger.info "Assuming #{encoding} for #{name}"
          content.force_encoding(encoding)
        rescue
          raise "Failure while setting encoding for #{name}"
        end

        content = remove_bom(content)

        begin
          content.encode('UTF-8')
        rescue
          raise "Failure while transcoding #{name} from #{content.encoding} to intermediate UTF-8 encoding"
        end
      end

      def with_extension(path, extension)
        path = path.strip
        match = path.match(/^.*\.#{extension}$/)
        match ? match[0] : "#{path}.#{extension}"
      end

      private

      def remove_bom(content)
        if bom = BOM_LIST_HEX[content.encoding]
          bom_size = bom.bytesize
          if content.bytes[0...bom_size] == bom.bytes # check it is indeed BOM
            return content.byteslice(bom_size...content.bytesize) # remove it
          end
        end
        content
      end
    end
  end
end
