module ChunkType
  END_TOKEN = "IEND"
  HIDDEN_TOKEN = "ruBy"
end

class ImageHide
  attr_accessor :image

  def initialize(image)
    @image = File.open(image, 'rb+')
  end

  def set_hidden_image(hidden_image)

  end

  def get_hidden_image
    if self.has_hidden_image?

    end
  end

  def has_hidden_image?
    # skip the first 8 bites
    @image.read(8)
    chunk_type = nil

    while chunk_type != ChunkType::END_TOKEN
      # find a more readable way to get the hex number
      #chunk_size = @base_@image.read(4).each_byte.map { |b| b.to_s(16) }.join.to_i(16)
      chunk_size = @image.read(4).unpack('H*').first.to_i(16)
      chunk_type = @image.read(4).encode("ASCII")

      puts("Chunk Size: #{chunk_size}")
      puts("Chunk Type: #{chunk_type}")

      if chunk_type == ChunkType::HIDDEN_TOKEN
        return true
      end

      @image.read(chunk_size)
      crc = @image.read(4).unpack('H*').first.to_i(16)

      puts("CRC: #{crc}")
    end

    return false
  end

  def is_png?

  end
end
