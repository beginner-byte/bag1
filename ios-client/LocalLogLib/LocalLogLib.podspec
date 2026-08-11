#
# Be sure to run `pod lib lint LocalLogLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LocalLogLib'
  s.version          = '0.1.0'
  s.summary          = '本地日志记录组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 这是一个本地日志记录组件，用于记录本地日志
                       DESC

  s.homepage         = 'https://github.com/Bytes(海亮)/LocalLogLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bytes(海亮)' => '244071821@qq.com' }
  s.source           = { :git => 'https://github.com/Bytes(海亮)/LocalLogLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'LocalLogLib/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LocalLogLib' => ['LocalLogLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'CocoaLumberjack/Swift'
end
