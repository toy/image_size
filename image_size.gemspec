# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'image_size'
  s.version     = '3.4.0'
  s.summary     = %q{Measure image size/dimensions using pure Ruby}
  s.description = %q{Measure following file dimensions: apng, avif, bmp, cur, emf, gif, heic, heif, ico, j2c, jp2, jpeg, jpx, mng, pam, pbm, pcx, pgm, png, ppm, psd, svg, swf, tiff, webp, xbm, xpm}
  s.homepage    = "https://github.com/toy/#{s.name}"
  s.authors     = ['Keisuke Minami', 'Ivan Kuchin']
  s.license     = 'Ruby'

  s.required_ruby_version = '>= 1.9.3'

  s.metadata = {
    'bug_tracker_uri'   => "https://github.com/toy/#{s.name}/issues",
    'changelog_uri'     => "https://github.com/toy/#{s.name}/blob/master/CHANGELOG.markdown",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'source_code_uri'   => "https://github.com/toy/#{s.name}",
  }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_development_dependency 'rspec', '~> 3.0'
  if RUBY_VERSION >= '2.5'
    s.add_development_dependency 'rubocop', '~> 1.22'
    s.add_development_dependency 'rubocop-rspec', '~> 2.0'
  end
end
