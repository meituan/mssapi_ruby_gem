desc 'Builds the mss-sdk gems'
task 'gems:build' do
  sh("rm -f *.gem")
  sh("gem build mss-sdk.gemspec")
  sh("gem build mss-sdk.gemspec")
end

task 'gems:push' do
  sh("gem push mss-sdk-#{$VERSION}.gem")
  sh("gem push mss-sdk-#{$VERSION}.gem")
end
