[![Gem Version](https://img.shields.io/gem/v/image_size?logo=rubygems)](https://rubygems.org/gems/image_size)
[![Build Status](https://img.shields.io/github/actions/workflow/status/toy/image_size/check.yml?logo=github)](https://github.com/toy/image_size/actions/workflows/check.yml)
[![Rubocop](https://img.shields.io/github/actions/workflow/status/toy/image_size/rubocop.yml?label=rubocop&logo=rubocop)](https://github.com/toy/image_size/actions/workflows/rubocop.yml)

# image_size

Measure image size/dimensions using pure Ruby.
Formats: `apng`, `avif`, `bmp`, `cur`, `emf`, `gif`, `heic`, `heif`, `ico`, `j2c`, `jp2`, `jpeg`, `jpx`, `mng`, `pam`, `pbm`, `pcx`, `pgm`, `png`, `ppm`, `psd`, `svg`, `swf`, `tiff`, `webp`, `xbm`, `xpm`.

## Installation

```sh
gem install image_size
```

### Bundler

Add to your `Gemfile`:

```ruby
gem 'image_size', '~> 3.0'
```

## Usage

```ruby
image_size = ImageSize.path('spec/images/jpeg/436x429.jpeg')

image_size.format       #=> :jpeg
image_size.width        #=> 436
image_size.height       #=> 429
image_size.w            #=> 436
image_size.h            #=> 429
image_size.size         #=> [436, 429]
image_size.size.to_s    #=> "436x429"
"#{image_size.size}"    #=> "436x429"
image_size.size.width   #=> 436
image_size.size.height  #=> 429
image_size.size.w       #=> 436
image_size.size.h       #=> 429
image_size.media_type   #=> "image/jpeg"
image_size.media_types  #=> ["image/jpeg"]
```

Or using `IO` object:

```ruby
image_size = File.open('spec/images/jpeg/436x429.jpeg', 'rb'){ |fh| ImageSize.new(fh) }
```

Any object responding to `read` and `eof?`:

```ruby
require 'image_size'

image_size = ImageSize.new(ARGF)
```

Works with `open-uri`, see [experimental HTTP server interface below](#experimental-fetch-image-meta-from-http-server):

```ruby
require 'image_size'
require 'open-uri'

image_size = URI.parse('http://www.rubycgi.org/image/ruby_gtk_book_title.jpg').open('rb') do |fh|
  ImageSize.new(fh)
end

image_size = open('http://www.rubycgi.org/image/ruby_gtk_book_title.jpg', 'rb') do |fh|
  ImageSize.new(fh)
end
```

Note that starting with version `2.0.0` the object given to `ImageSize` will not be rewound before or after use.
So rewind if needed before passing to `ImageSize` and/or rewind after passing to `ImageSize` before reading data.

```ruby
require 'image_size'

File.open('spec/images/jpeg/436x429.jpeg', 'rb') do |fh|
  image_size = ImageSize.new(fh)

  fh.rewind
  data = fh.read
end

File.open('spec/images/jpeg/436x429.jpeg', 'rb') do |fh|
  data = fh.read
  fh.rewind

  image_size = ImageSize.new(fh)
end
```

### Experimental: fetch image meta from HTTP server

If server recognises Range header, only needed chunks will be fetched even for TIFF images, otherwise required amount
of data will be fetched, in most cases first few kilobytes (TIFF images is an exception).

```ruby
require 'image_size/uri'

url = 'http://upload.wikimedia.org/wikipedia/commons/b/b4/Mardin_1350660_1350692_33_images.jpg'
p ImageSize.url(url).size
```

This interface is as fast as dedicated gem fastimage for images with meta information in the header:

```ruby
url = 'http://upload.wikimedia.org/wikipedia/commons/b/b4/Mardin_1350660_1350692_33_images.jpg'
puts Benchmark.measure{ p FastImage.size(url) }
```
```
[9545, 6623]
  0.004176   0.001974   0.006150 (  0.282889)
```
```ruby
puts Benchmark.measure{ p ImageSize.url(url).size }
```
```
[9545, 6623]
  0.005604   0.001406   0.007010 (  0.238629)
```

And considerably faster for images with meta information at the end of file:

```ruby
url = "https://upload.wikimedia.org/wikipedia/commons/c/c7/Curiosity%27s_Vehicle_System_Test_Bed_%28VSTB%29_Rover_%28PIA15876%29.tif"
puts Benchmark.measure{ p FastImage.size(url) }
```
```
[7360, 4912]
  0.331284   0.247295   0.578579 (  6.027051)
```
```ruby
puts Benchmark.measure{ p ImageSize.url(url).size }
```
```
[7360, 4912]
  0.006247   0.001045   0.007292 (  0.197631)
```

## Licence

This code is free to use under the terms of the [Ruby's licence](LICENSE.txt).

Original author: Keisuke Minami <keisuke@rccn.com>.\
Further development 2010-2024 Ivan Kuchin https://github.com/toy/image_size
