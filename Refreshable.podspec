Pod::Spec.new do |s|
  s.name = 'Refreshable'
  s.version = '2.0.0'
  s.license = 'MIT'
  s.summary = 'Pull to refresh and load more function for UIScrollView'

  s.homepage = 'https://github.com/hoangtaiki/Refreshable'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = { 'Hoangtaiki' => 'duchoang.vp@gmail.com' }
  s.source = { :git => 'https://github.com/hoangtaiki/Refreshable.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.9'

  s.source_files = 'Refreshable/**/*.swift'
  s.ios.frameworks = 'UIKit', 'Foundation'
end
