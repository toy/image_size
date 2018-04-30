[![Gem Version](https://img.shields.io/gem/v/image_size.svg?style=flat)](https://rubygems.org/gems/image_size)
[![Build Status](https://img.shields.io/travis/toy/image_size/master.svg?style=flat)](https://travis-ci.org/toy/image_size)

# image_size

measure image size using pure Ruby
formats: `apng`, `bmp`, `cur`, `gif`, `jpeg`, `ico`, `mng`, `pbm`, `pcx`, `pgm`, `png`, `ppm`, `psd`, `swf`, `tiff`, `xbm`, `xpm`, `webp`

## Download

The latest version of image\_size can be found at https://github.com/toy/image_size

## Installation

```shell
gem install image_size
```

## Usage

```ruby
image_size = ImageSize.path('spec/images/jpeg/320x240.jpeg')
image_size.format       #=> :jpec
image_size.width        #=> 320
image_size.height       #=> 240
image_size.w            #=> 320
image_size.h            #=> 240
image_size.size         #=> [320, 240]
```

`width` and `height` have aliases `w` and `h`.

## Examples

Note that starting with version `2.0.0` the `IO` given to `ImageSize` will not be rewound before or after use.
So rewind if needed before passing to `ImageSize` and/or rewind after passing to `ImageSize` before reading data.

```ruby
require 'image_size'

ImageSize.path('spec/test.jpg')

File.open('spec/test.jpg', 'rb') do |fh|
  image_size = ImageSize.new(fh)
  fh.rewind
  data = fh.read
end

File.open('spec/test.jpg', 'rb') do |fh|
  data = fh.read
  fh.rewind
  image_size = ImageSize.new(fh)
end
```

Any object responding to `read` and `eof?` will do:

```ruby
require 'image_size'

ImageSize.new(ARGF)
```

Works with `open-uri` if needed:

```ruby
require 'image_size'
require 'open-uri'

URI.parse('http://www.rubycgi.org/image/ruby_gtk_book_title.jpg').open('rb') do |fh|
  ImageSize.new(fh)
end

open('http://www.rubycgi.org/image/ruby_gtk_book_title.jpg', 'rb') do |fh|
  ImageSize.new(fh)
end
```

## Licence

This code is free to use under the terms of the Ruby's licence.

## Contact

Original author: "Keisuke Minami": mailto:keisuke@rccn.com
Further development by Ivan Kuchin https://github.com/toy/image_size
