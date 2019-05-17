# ChangeLog

## unreleased

## v2.0.1 (2019-05-17)

* Adapt to frozen string literals [@toy](https://github.com/toy)

## v2.0.0 (2018-05-01)

* Allow any class responding to `read` and `eof?` to be passed to `ImageSize` [@toy](https://github.com/toy)
* Introduce `rubocop` [@toy](https://github.com/toy)
* Use `File.open` instead of `Kernel#open` [@toy](https://github.com/toy)
* Don’t rewind `IO` before or after usage [@toy](https://github.com/toy)
* Enhance readme [@toy](https://github.com/toy)

## v1.5.0 (2016-11-20)

* Support `WEBP` images [@toy](https://github.com/toy)
* Cleanup `GIF`, `PPM` and `SWF` magic number matching [@toy](https://github.com/toy)
* Fix `GIF` magic number (matched `GIF8,a`) [@toy](https://github.com/toy)
* Detect `APNG` images by `acTL` chunk [@toy](https://github.com/toy)
* Support `MNG` images [@toy](https://github.com/toy)

## v1.4.2 (2016-02-18)

* Fixed license in gemspec to be Ruby [#10](https://github.com/toy/image_size/issues/10) [@toy](https://github.com/toy)

## v1.4.1 (2014-11-19)

* Missed `ICO` and `CUR` in description [@toy](https://github.com/toy)

## v1.4.0 (2014-11-19)

* Detecting `ICO` and `CUR` images [@toy](https://github.com/toy)

## v1.3.1 (2014-06-24)

* Fix reading `JPEGs` with extraneous bytes [@toy](https://github.com/toy)

## v1.3.0 (2014-04-06)

* Raise `FormatError` instead of `RuntimeError` [@toy](https://github.com/toy)

## v1.2.0 (2014-02-01)

* Basic handling of `SVG` (only width and height attributes) [@toy](https://github.com/toy)
* Enhance matching `PCX` [@toy](https://github.com/toy)

## v1.1.5 (2013-12-23)

* Fix reading dimensions of `BMP v2` and `BMP v3` [@toy](https://github.com/toy)
* Fix swapped `PSD` width (columns) and height (rows) [#9](https://github.com/toy/image_size/issues/9) [@toy](https://github.com/toy)
* Replace square test images with rectangle ones [@toy](https://github.com/toy)

## v1.1.4 (2013-11-05)

* Close instead of only rewinding `IO` instances [@toy](https://github.com/toy)
* Add `.travis.yml` and supporting files [#8](https://github.com/toy/image_size/pull/8) [@petergoldstein](https://github.com/petergoldstein)

## v1.1.3 (2013-07-24)

* Enforce binary encoding of data returned by `ImageReader#[]` [#6](https://github.com/toy/image_size/issues/6) [@toy](https://github.com/toy)

## v1.1.2 (2013-02-24)

* Explicitly set encoding to `ASCII-8BIT` as for `ruby2.0.0-p0` it will be `UTF-8` by default [#5](https://github.com/toy/image_size/pull/5) [@walf443](https://github.com/walf443)

## v1.1.1 (2012-06-19)

* Fix exception in message for exception [#3](https://github.com/toy/image_size/pull/3) [@yachi](https://github.com/yachi)

## v1.1.0 (2012-02-25)

* Rework most code [@toy](https://github.com/toy)
* `Size` class instead of dynamically adding `to_s` method to size array [@toy](https://github.com/toy)
* `ImageSize.path`, more examples [@toy](https://github.com/toy)
* Added support for `Tempfile`, as well as fixed bug when running `ImageSize` on the same `IO` stream twice [#2](https://github.com/toy/image_size/pull/2) [@kanevski](https://github.com/kanevski)

## v1.0.6 (2012-02-08)

* Internal gem changes [@toy](https://github.com/toy)

## v1.0.5 (2012-02-04)

* Fix getting `SWF` dimensions for ruby 1.9 [@toy](https://github.com/toy)
* Fix determining `PCX` for ruby1.9 [@toy](https://github.com/toy)
* Enhance `SWF` checking [@toy](https://github.com/toy)

## v1.0.4 (2011-12-16)

* Internal gem changes [@toy](https://github.com/toy)

## v1.0.3 (2011-02-21)

* Fix permissions on `lib/image_size.rb` from `700` to `644` [#1](https://github.com/toy/image_size/issues/1) [@toy](https://github.com/toy)

## v1.0.2 (2010-12-15)

* Internal gem changes [@toy](https://github.com/toy)

## v1.0.1 (2010-12-15)

* Internal gem changes [@toy](https://github.com/toy)

## v1.0.0 (2010-11-01)

* Initial commit [@toy](https://github.com/toy)
