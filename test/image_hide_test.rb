require "image_hide"
require 'test/unit'

class ImageHideUT < Test::Unit::TestCase
  def setup
    @base_image = File.open('test/images/base_image.png', 'rb+')
    @hidden_image = 'test/images/hidden_image.png'
  end

  def test_set_hidden_image
    # XXX need to create an idempotent unit test
    image_hide = ImageHide.new @base_image
    assert_equal(image_hide.seek_token, ChunkType::END_TOKEN)

    merged_image = image_hide.set_hidden_image @hidden_image
    merged_image = ImageHide.new merged_image
    assert_equal(merged_image.seek_token, ChunkType::HIDDEN_TOKEN)
  end

  def test_extract_hidden_image
    pass
  end

  def test_crc_calculation
    # verify crc calculation is correct by calculating a crc from a PNG

  end
end
