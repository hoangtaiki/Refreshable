Pod::Spec.new do |s|
  s.name = 'Refreshable'
  s.version = '1.2.0'
  s.license = 'MIT'
  s.summary = 'Pull to refresh and load more function for UIScrollView'

  s.homepage = 'https://github.com/harrytrn/Refreshable'
  s.license = { :type => 'MIT', :file => 'LICENSE.md' }
  s.authors = { 'Harry Tran' => 'duchoang.vp@gmail.com' }
  s.source = { :git => 'https://github.com/harrytrn/Refreshable.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*.swift'
  s.ios.frameworks = 'UIKit', 'Foundation'
end
