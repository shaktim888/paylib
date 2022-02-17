#
# Be sure to run `pod lib lint paylib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'paylib'
  s.version          = '2019.12.20'
  s.summary          = 'A short description of paylib.'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/pfzq303/paylib'
  # s.screenshots     = 'www.example/Users/hqq/Documents/tzt/code/paylib/paylib.podspec.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pfzq303' => 'pfzq303' }
  s.source           = { :git => 'https://github.com/pfzq303/paylib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.source_files = 'appleIAP/*.h','paylib/Classes/**/*'
  s.vendored_libraries = 'appleIAP/*.a'

  s.public_header_files = 'appleIAP/**/*.h'
  s.requires_arc = false
  s.static_framework = true
  s.prefix_header_file = 'prefix.pch'
  #s.frameworks = 'MediaPlayer', 'GameController'
end
