# ImageHide
```
###############################################################################################
#  __     __    __     ______     ______     ______     __  __     __     _____     ______    #
# /\ \   /\ "-./  \   /\  __ \   /\  ___\   /\  ___\   /\ \_\ \   /\ \   /\  __-.  /\  ___\   #
# \ \ \  \ \ \-./\ \  \ \  __ \  \ \ \__ \  \ \  __\   \ \  __ \  \ \ \  \ \ \/\ \ \ \  __\   #
#  \ \_\  \ \_\ \ \_\  \ \_\ \_\  \ \_____\  \ \_____\  \ \_\ \_\  \ \_\  \ \____-  \ \_____\ #
#   \/_/   \/_/  \/_/   \/_/\/_/   \/_____/   \/_____/   \/_/\/_/   \/_/   \/____/   \/_____/ #
###############################################################################################
```

## About

ImageHide is a library to hide an image inside another image!

## What it does

* Insert hidden image inside chosen PNG
* Extract hidden image from chosen PNG

## Examples

Insert an image inside a png image you have. It will be saved in the
original png image!
```ruby
> ih = ImageHide.new "path/to/image.png"
> ih.set_hidden_image("path/to/hidden/image.jpg")
> ih.has_hidden_image?
=> true
```

extract the image
```ruby
> ih = ImageHide.new "path/to/image_with_hidden_image.png"
> bytes_content = ih.get_hidden_image()
```

or create a file with the hidden image directly
```ruby
> ih = ImageHide.new "path/to/image_with_hidden_image.png"
> hidden_image = ih.get_hidden_image_as_file("my_hidden_image.jpg")
```
