# image_size

measure image size using pure Ruby
formats: `apng`, `bmp`, `cur`, `gif`, `jpeg`, `ico`, `mng`, `pbm`, `pcx`, `pgm`, `png`, `ppm`, `psd`, `swf`, `tiff`, `xbm`, `xpm`, `webp`

[![Build Status](https://travis-ci.org/toy/image_size.png?branch=master)](https://travis-ci.org/toy/image_size)

## Download

The latest version of image\_size can be found at http://github.com/toy/image_size

## Installation

    gem install image_size

## Usage

    image_size = ImageSize.path('spec/images/jpeg/320x240.jpeg')
    image_size.format       #=> :jpec
    image_size.width        #=> 320
    image_size.height       #=> 240
    image_size.size         #=> [320, 240]

`width` and `height` have aliases `w` and `h`.

## Examples

    require 'image_size'

    ImageSize.path('spec/test.jpg')

    open('spec/test.jpg', 'rb') do |fh|
      ImageSize.new(fh)
    end


    require 'image_size'
    require 'open-uri'

    open('http://www.rubycgi.org/image/ruby_gtk_book_title.jpg', 'rb') do |fh|
      ImageSize.new(fh)
    end

    open('http://www.rubycgi.org/image/ruby_gtk_book_title.jpg', 'rb') do |fh|
      data = fh.read
      ImageSize.new(data)
    end

## Licence

This code is free to use under the terms of the Ruby's licence.

## Contact

Original author: "Keisuke Minami": mailto:keisuke@rccn.com
