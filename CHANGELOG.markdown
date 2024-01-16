# ChangeLog

## unreleased

## v3.4.0 (2024-01-16)

* Provide access to media types using media_type and media_types methods [#22](https://github.com/toy/image_size/issues/22) [@toy](https://github.com/toy)
* Allow fetching from HTTP server by requiring image_size/uri [@toy](https://github.com/toy)
* Fix for ArgumentError when requiring only image_size/uri_reader (without image_size) [@toy](https://github.com/toy)
* Require ruby 1.9.3 [@toy](https://github.com/toy)

## v3.3.0 (2023-05-30)

* Support `HEIF` (`HEIC` and `AVIF`) images [#19](https://github.com/toy/image_size/issues/19) [@toy](https://github.com/toy)
* Fix handling `JPEG 2000` 64 bit size boxes [@toy](https://github.com/toy)

## v3.2.0 (2022-11-03)

* Support `EMF` images [#21](https://github.com/toy/image_size/pull/21) [@opoudjis](https://github.com/opoudjis)

## v3.1.0 (2022-09-17)

* Document experimental fetching from http server [#18](https://github.com/toy/image_size/issues/18) [@toy](https://github.com/toy)
* Improve experimental fetching of image meta from http server by reading only required amount of data when server does not support range header [@toy](https://github.com/toy)

## v3.0.2 (2022-05-19)

* Fix handling empty files [#20](https://github.com/toy/image_size/issues/20) [@toy](https://github.com/toy)

## v3.0.1 (2021-10-21)

* Fix reading file chunks starting after EOF and reading chunks non-consecutively [toy/image_optim_rails#12](https://github.com/toy/image_optim_rails/issues/12) [@toy](https://github.com/toy)

## v3.0.0 (2021-10-17)

* Read only required chunks of data for files and seekable IOs [@toy](https://github.com/toy)
* Raise `FormatError` whenever reading data returns less data than expected [#12](https://github.com/toy/image_size/issues/12) [@toy](https://github.com/toy)
* Add `w`/`width` and `h`/`height` accessors to `Size` [@toy](https://github.com/toy)
* Experimental efficient fetching of image meta from http server supporting range [@toy](https://github.com/toy)

## v2.1.2 (2021-08-21)

* Fix for pcx on big endian systems by forcing reading dimensions in little endian byte order [#15](https://github.com/toy/image_size/issues/15) [#16](https://github.com/toy/image_size/pull/16) [@mtasaka](https://github.com/mtasaka)

## v2.1.1 (2021-07-04)

* Add actual license texts, assuming old dual Ruby/GPLv2 license [#14](https://github.com/toy/image_size/issues/14) [@toy](https://github.com/toy)

## v2.1.0 (2020-08-09)

* Add handling of JPEG 2000: part 1 (jp2), part 2 (jpx) and codestream (j2c) [#13](https://github.com/toy/image_size/issues/13) [@toy](https://github.com/toy)
* Correct handling of pam images and cleanup handling of Netpbm images (pbm, pgm, pnm) [@toy](https://github.com/toy)

## v2.0.2 (2019-07-14)

* Remove deprecated `rubyforge_project` attribute from gemspec [rubygems/rubygems#2436](https://github.com/rubygems/rubygems/pull/2436) [@toy](https://github.com/toy)

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
