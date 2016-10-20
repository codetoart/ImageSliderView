#
# Be sure to run `pod lib lint ImageSliderView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ImageSliderView'
  s.version          = '0.0.1'
  s.summary          = 'View to display multiple images from a remote data source'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library is used to quickly build a view to display multiple images from a remote data source.
It also has functionality to view fullscreen images.
                       DESC

  s.homepage         = 'https://github.com/codetoart/ImageSliderView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Priyank Tiwari' => 'priyank@codetoart.com' }
  s.source           = { :git => 'https://github.com/codetoart/ImageSliderView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ImageSliderView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ImageSliderView' => ['ImageSliderView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AsyncImageView', '1.6'
  s.dependency 'SnapKit', '0.22.0'

end
