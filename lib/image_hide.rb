require 'stringio'
require 'zlib'

module ChunkType
  END_TOKEN = "IEND"
  HIDDEN_TOKEN = "ruBy"
end

class ImageHide
  attr_accessor :image

  def initialize(image)
    @image_path = image
    @image = File.open(image, 'rb+')
  end

  def is_png?(image)
    return true
  end

  def generate_crc(token, image_bytes)
    return Zlib::crc32("#{token}#{image_bytes}")
  end

  # Hides the given image into the base image
  def set_hidden_image(hidden_image)
    if not (self.is_png? hidden_image)
      # convert image to png if possible
    end

    token = self.seek_token
    if token != ChunkType::END_TOKEN
      puts("image already has a hidden image")
      return false
    end

    byte_pos = @image.pos
    @image.pos = 0
    # don't save to file, return a StringIO instead
    merged_image = StringIO.new
    merged_image.write(@image.read())

    hidden_bytes = hidden_image.read()
    crc = self.generate_crc(ChunkType::HIDDEN_TOKEN, hidden_bytes)

    # write chunk size as big endian integer (!i)
    length = [hidden_bytes.unpack("C*").length].pack('!i')

    # TODO Refactor this pretty plox
    merged_image.pos = byte_pos
    merged_image.write(length)
    merged_image.write(ChunkType::HIDDEN_TOKEN)
    merged_image.write(hidden_bytes)
    merged_image.write([crc].pack('!i'))
    merged_image.write([0].pack('!i'))
    merged_image.write(ChunkType::END_TOKEN)

    return merged_image
  end

  # Extracts the hidden image and returns it as a valid PNG
  def get_hidden_image(image)
    if self.seek_token(image) == ChunkType::HIDDEN_TOKEN

    end
  end

  # returns a HIDDEN_TOKEN if found, else, an END_TOKEN
  # and leaves the image in the byte where the token was found
  def seek_token(image=@image)
    # restart file read position so the function becomes idempotent, also, skip first 8 bytes
    @image.pos = 8
    chunk_type = nil

    while chunk_type != ChunkType::END_TOKEN
      # find a more readable way to get the hex number
      # please read here if you are curious about pack/unpack http://blog.bigbinary.com/2011/07/20/ruby-pack-unpack.html
      chunk_size = @image.read(4).unpack('H*').first.to_i(16)
      chunk_type = @image.read(4).encode("ASCII")

      puts("Chunk Size: #{chunk_size}")
      puts("Chunk Type: #{chunk_type}")

      if chunk_type == ChunkType::HIDDEN_TOKEN
        return ChunkType::HIDDEN_TOKEN
      end

      @image.read(chunk_size)
      crc = @image.read(4).unpack('H*').first.to_i(16)

      puts("CRC: #{crc}")
    end

    # setup position so we can write just before the END_TOKEN
    @image.pos = (@image.pos - 8)
    return ChunkType::END_TOKEN
  end
end
