require File.dirname(__FILE__) + '/test_helper.rb'

class TestImageSize < Test::Unit::TestCase

  def setup
    @dir = File.dirname(__FILE__)
    @data = [
      ['4_1_2.gif',       :gif,  668, 481],
      ['2-4-7.png',       :png,  640, 532],
      ['tokyo_tower.jpg', :jpeg, 320, 240],
      ['bmp.bmp',         :bmp,   50,  50],
      ['pgm.pgm',         :pgm,   90,  55],
      ['pbm.pbm',         :pbm,   85,  55],
      ['cursor.xbm',      :xbm,   16,  16],
      ['tiff.tiff',       :tiff,  64,  64],
      ['test.xpm',        :xpm,   32,  32],
      ['tower_e.psd',     :psd,   20,  20],
      ['pcx.pcx',         :pcx,   70,  60],
      ['detect.swf',      :swf,  450, 200],
      ['test_helper.rb',  nil,   nil, nil],
    ]
  end

  def teardown
  end

  def test_string
    @data.each do |file_name, format, widht, height|
      open(File.join(@dir, file_name), 'rb') do |fh|
        img_data = fh.read

        img = ImageSize.new(img_data)
        assert_equal(format, img.format)
        assert_equal(widht,  img.width)
        assert_equal(height, img.height)
      end
    end
  end

  def test_io
    @data.each do |file_name, format, widht, height|
      open(File.join(@dir, file_name), 'rb') do |fh|
        img = ImageSize.new(fh)
        assert_equal(format, img.format)
        assert_equal(widht,  img.width)
        assert_equal(height, img.height)
      end
    end
  end
end
