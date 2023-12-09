#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint alikit4.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'alibc4'
  s.version          = '0.0.1'
  s.summary          = 'alibcv4 for android and ios.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  s.vendored_frameworks = "framework/**/*.framework"
  s.frameworks = 'JavaScriptCore','CoreMotion','CoreTelephony'
  s.libraries = 'resolv','c++','icucore','sqlite3'
  s.resources = ['bundle/*.bundle']
  #记得添加编译参数:,'-lstdc++','-ObjC'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
