[![Gem Version](https://img.shields.io/gem/v/image_size?logo=rubygems)](https://rubygems.org/gems/image_size)
[![Build Status](https://img.shields.io/github/workflow/status/toy/image_size/check/master?logo=github)](https://github.com/toy/image_size/actions/workflows/check.yml)

# image_size

Measure image size using pure Ruby.
Formats: `apng`, `bmp`, `cur`, `gif`, `ico`, `j2c`, `jp2`, `jpeg`, `jpx`, `mng`, `pam`, `pbm`, `pcx`, `pgm`, `png`, `ppm`, `psd`, `svg`, `swf`, `tiff`, `webp`, `xbm`, `xpm`.

## Installation

```sh
gem install image_size
```

### Bundler

Add to your `Gemfile`:

```ruby
gem 'image_size', '~> 2.0'
```

## Usage

```ruby
image_size = ImageSize.path('spec/images/jpeg/436x429.jpeg')

image_size.format       #=> :jpec
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

Works with `open-uri` if needed:

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

## Licence

This code is free to use under the terms of the [Ruby's licence](LICENSE.txt).

Original author: Keisuke Minami <keisuke@rccn.com>.\
Further development 2010-2021 Ivan Kuchin https://github.com/toy/image_size
