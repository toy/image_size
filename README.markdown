# image_size

measure image size using pure Ruby
formats: PCX, PSD, XPM, TIFF, XBM, PGM, PBM, PPM, BMP, JPEG, PNG, GIF, SWF

## Download

The latest version of image\_size can be found at http://github.com/toy/image_size

## Installation

    gem install image_size

## Simple Example

    ruby "image_size"
    ruby "open-uri"

    open("http://www.rubycgi.org/image/ruby_gtk_book_title.jpg", "rb") do |fh|
      p ImageSize.new(fh.read).size
    end

## Licence

This code is free to use under the terms of the Ruby's licence.

## Contact

Original author: "Keisuke Minami": mailto:keisuke@rccn.com
