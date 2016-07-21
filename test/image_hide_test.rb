require 'image_hide'
require 'test/unit'

class ImageHideUT < Test::Unit::TestCase
  def setup
    # setting them up as StringIO so test become idempotent
    base_image = File.open('test/images/base_image.png', 'rb+')
    @base_image = StringIO.new base_image.read()

    hidden_image = File.open('test/images/hidden_image.png')
    @hidden_image = StringIO.new hidden_image.read()
  end

  def test_set_hidden_image
    image_hide = ImageHide.new @base_image
    assert_equal(image_hide.seek_token, ChunkType::END_TOKEN)

    merged_image = image_hide.set_hidden_image @hidden_image
    merged_image = ImageHide.new merged_image
    assert_equal(merged_image.seek_token, ChunkType::HIDDEN_TOKEN)
  end

  def test_extract_hidden_image
    image_hide = ImageHide.new @base_image
    merged_image = image_hide.set_hidden_image @hidden_image

    image_hide = ImageHide.new merged_image
    hidden_image = image_hide.get_hidden_image

    assert_equal(hidden_image.read(), @hidden_image.read())
  end

  # verify crc calculation is correct by calculating a crc from a PNG
  def test_crc_calculation
  end

  def test_rewind_to_token
    # make the method accessible for unit testing
    ImageHide.send(:public, :rewind_to_token)

    image_hide = ImageHide.new @base_image
    assert_equal(image_hide.rewind_to_token(ChunkType::HIDDEN_TOKEN), -1)

    image_hide.image.read()
    image_size = image_hide.image.tell
    assert_equal(image_hide.rewind_to_token(ChunkType::END_TOKEN), image_size - 12)
  end
end
