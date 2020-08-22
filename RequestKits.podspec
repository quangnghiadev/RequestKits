#
# Be sure to run `pod lib lint RequestKits.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RequestKits'
  s.version          = '1.0.0'
  s.summary          = 'RequestKits is using for execute API request.'
  s.description      = <<-DESC
Combine of Alamofire, RxSwift, and Foundation framework.
                       DESC

  s.homepage         = 'https://github.com/nghiadev95/RequestKits.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nghia Nguyen' => 'quangnghiadev@gmail.com' }
  s.source           = { :git => 'https://github.com/nghiadev95/RequestKits.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'Sources/RequestKits/*.swift'
  
  s.dependency 'RxSwift', '5.1.1'
  s.dependency 'Alamofire', '5.1.0'
  
end
