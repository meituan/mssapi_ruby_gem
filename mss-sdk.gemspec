Gem::Specification.new do |s|
  s.name = 'mss-sdk'
  s.version = File.read(File.expand_path('../VERSION', __FILE__)).strip
  s.summary = 'MSS SDK for Ruby'
  s.description = <<-DESCRIPTION.strip
Meituan Storage Service SDK for Ruby.
  DESCRIPTION
  s.license = 'Apache 2.0'
  s.author = 'Meituan Storage Service'
  s.homepage = 'https://mos.meituan.com'
  s.email = 'mos@meituan.com'

  s.add_dependency('nokogiri', '~> 1.4')
  s.add_dependency('json', '~> 1.4')

  s.files = [
    'ca-bundle.crt',
    'rails/init.rb',    # for compatibility with older versions of rails
    '.yardopts',
    'README.md',
    'LICENSE.txt',
  ]
  s.files += Dir['lib/**/*.rb'] - ['lib/mss-sdk.rb']
  s.files += Dir['lib/**/*.yml']
  s.files += ['lib/mss-sdk.rb']

  s.bindir = 'bin'
  s.executables << 'mss-rb'
end
