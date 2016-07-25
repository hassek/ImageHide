require 'logger'
require 'zlib'

module ChunkType
  # PNG Chunk types

  END_TOKEN = "IEND"
  HIDDEN_TOKEN = "ruBy"

  def self.include_value?(value)
    constants.find {|token| const_get(token)==value}
  end
end

class ImageHide
  # Image Hide allows you to hide an image inside another PNG Image
  #
  # To use it the initialized object needs to be the PNG image.
  #
  # example:
  #
  #   ih = ImageHide.new "path/to/image.png"
  #   merged_image = ih.set_hidden_image("path/to/hidden/image")
  #
  #   ih = ImageHide.new merged_image
  #   hidden_image = ih.get_hidden_image()


  REQUIRED_METHODS = [:read, :pos, :tell, :rewind, :binmode, :write]
  BIG_ENDIAN = "L>"

  attr_accessor :image

  private

    def sanitize(image)
      # if it doesn't implements this methods, assume is a file path
      if not (REQUIRED_METHODS.all? {|method| image.respond_to?(method)})
        image = File.open(image, 'rb+')
      end

      image.binmode.rewind
      return image
    end

    def rewind_to_token(tokens=ChunkType.constants)
      # rewind to a valid ChunkType position
      # return:
      #   position
      #   -1 if no token found

      # Always assume is a well formed PNG file
      # keep going unless we reach the beggining of the image
      while @image.tell != 0
        @image.pos = @image.tell - 4
        token = @image.read(4)
        if ChunkType.include_value?(token)
          @image.pos = @image.tell - 8
          return @image.tell
        else
          # keep looking for the token
          @image.pos = @image.tell - 1
        end
      end

      return -1
    end

  public

    def initialize(image, log_level=Logger::WARN)
      # Accepted initializations
      #
      # * image path
      # * File Object
      # * StringIO Object
      # * Any other object that responds to the REQUIRED_METHODS

      super()

      @image = sanitize(image)
      @logger = Logger.new(STDOUT)
      @logger.level = log_level
    end

    # TODO to be implemented
    def is_png?(image)
      return true
    end

    def generate_crc(token, image_bytes)
      return [Zlib::crc32("#{token}#{image_bytes}")].pack(BIG_ENDIAN)
    end

    def set_hidden_image(hidden_image)
      # Hides the given image into the base PNG image

      hidden_image = sanitize(hidden_image)

      token = self.seek_token
      if token != ChunkType::END_TOKEN
        @logger.warn("image already has a hidden image")
        return false
      end

      hidden_bytes = hidden_image.read()
      crc = self.generate_crc(ChunkType::HIDDEN_TOKEN, hidden_bytes)
      length = [hidden_bytes.unpack("C*").length].pack(BIG_ENDIAN)

      ordered_data = [length, ChunkType::HIDDEN_TOKEN, hidden_bytes, crc,
       [0].pack(BIG_ENDIAN), ChunkType::END_TOKEN]

      ordered_data.each { |data| @image.write(data)}

      @image.rewind
      hidden_image.rewind
      return @image
    end

    def get_hidden_image
      # Extracts the hidden image and returns it as a valid PNG
      if self.seek_token(@image) == ChunkType::HIDDEN_TOKEN
        chunk_size = @image.read(4).unpack(BIG_ENDIAN).first

        # skip token
        @image.read(4)
        content = @image.read(chunk_size)
        return content
      end
    end

    def seek_token(image=@image)
      # returns a HIDDEN_TOKEN if found, else, an END_TOKEN
      # and leaves the image in the byte where the token was found

      # restart file read position so the function becomes idempotent, also, skip first 8 bytes
      @image.pos = 8
      chunk_type = nil

      while chunk_type != ChunkType::END_TOKEN
        # please read here if you are curious about pack/unpack http://blog.bigbinary.com/2011/07/20/ruby-pack-unpack.html
        chunk_size = @image.read(4).unpack(BIG_ENDIAN).first
        chunk_type = @image.read(4).encode("ASCII")

        @logger.debug("Chunk Size: #{chunk_size}")
        @logger.debug("Chunk Type: #{chunk_type}")
        if chunk_type == ChunkType::HIDDEN_TOKEN
          rewind_to_token(ChunkType::HIDDEN_TOKEN)
          return ChunkType::HIDDEN_TOKEN
        end

        @image.read(chunk_size)
        crc = @image.read(4).unpack(BIG_ENDIAN).first

        @logger.debug("CRC: #{crc}")
      end

      rewind_to_token(ChunkType::END_TOKEN)
      return ChunkType::END_TOKEN
    end
end
