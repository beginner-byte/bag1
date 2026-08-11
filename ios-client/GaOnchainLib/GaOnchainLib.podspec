#
# Be sure to run `pod lib lint GaOnchainLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GaOnchainLib'
  s.version          = '1.0.0'
  s.summary          = 'GaOnchain 请求组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
GaOnchainLib 是一个用于处理 GaOnchain 链上数据请求的 iOS 组件库。
提供了简单易用的 API 接口，支持链上数据查询、交易处理等功能。
适用于需要集成 GaOnchain 服务的 iOS 应用。
                       DESC

  s.homepage         = 'https://github.com/panghailiang/GaOnchainLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'panghailiang' => '244071821@qq.com' }
  s.source           = { :git => 'https://github.com/panghailiang/GaOnchainLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'GaOnchainLib/Classes/**/*'
  
  s.resource_bundles = {
    'GaOnchainLib' => ['GaOnchainLib/Classes/Config/*.json']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
