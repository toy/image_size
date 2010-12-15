require 'rake'
require 'jeweler'
require 'rake/gem_ghost_task'

name = 'image_size'

Jeweler::Tasks.new do |gem|
  gem.name = name
  gem.summary = %Q{Measure image size using pure Ruby}
  gem.description = %Q{Measure following file dimensions: PCX, PSD, XPM, TIFF, XBM, PGM, PBM, PPM, BMP, JPEG, PNG, GIF, SWF}
  gem.homepage = "http://github.com/toy/#{name}"
  gem.license = 'MIT'
  gem.authors = ['Keisuke Minami', 'Ivan Kuchin']
  gem.add_development_dependency 'jeweler', '~> 1.5.1'
  gem.add_development_dependency 'rake-gem-ghost'
end
Jeweler::RubygemsDotOrgTasks.new
Rake::GemGhostTask.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end
task :default => :test
