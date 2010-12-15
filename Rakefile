require 'rubygems'
require 'rake'

name = 'image_size'

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name = name
    gem.summary = %Q{measure image size using pure Ruby}
    gem.description = %Q{measure following file dimensions: PCX, PSD, XPM, TIFF, XBM, PGM, PBM, PPM, BMP, JPEG, PNG, GIF, SWF}
    gem.homepage = "http://github.com/toy/#{name}"
    gem.authors = ['Keisuke Minami', 'Ivan Kuchin']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :test => :check_dependencies
task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
