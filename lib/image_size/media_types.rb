# frozen_string_literal: true

class ImageSize
  MEDIA_TYPES = {
    apng: %w[image/apng image/vnd.mozilla.apng],
    avif: %w[image/avif],
    bmp: %w[image/bmp],
    cur: %w[image/vnd.microsoft.icon],
    emf: %w[image/emf],
    gif: %w[image/gif],
    heic: %w[image/heic image/heif],
    ico: %w[image/x-icon image/vnd.microsoft.icon],
    j2c: %w[image/j2c],
    jp2: %w[image/jp2],
    jpeg: %w[image/jpeg],
    jpx: %w[image/jpx],
    mng: %w[video/x-mng image/x-mng],
    pam: %w[image/x-portable-arbitrarymap],
    pbm: %w[image/x-portable-bitmap image/x-portable-anymap],
    pcx: %w[image/x-pcx image/vnd.zbrush.pcx],
    pgm: %w[image/x-portable-graymap image/x-portable-anymap],
    png: %w[image/png],
    ppm: %w[image/x-portable-pixmap image/x-portable-anymap],
    psd: %w[image/vnd.adobe.photoshop],
    svg: %w[image/svg+xml],
    swf: %w[application/x-shockwave-flash application/vnd.adobe.flash.movie],
    tiff: %w[image/tiff],
    webp: %w[image/webp],
    xbm: %w[image/x-xbitmap],
    xpm: %w[image/x-xpixmap],
  }.freeze
end
