# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'image_size'
  s.version     = '2.0.1'
  s.summary     = %q{Measure image size using pure Ruby}
  s.description = %q{Measure following file dimensions: apng, bmp, cur, gif, jpeg, ico, mng, pbm, pcx, pgm, png, ppm, psd, swf, tiff, xbm, xpm, webp}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Keisuke Minami', 'Ivan Kuchin']
  s.license     = 'Ruby'

  s.rubyforge_project = s.name

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
  if RUBY_VERSION >= '2.2'
    s.add_development_dependency 'rubocop', '~> 0.59'
  end
end
