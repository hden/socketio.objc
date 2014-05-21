Pod::Spec.new do |s|
  s.name         = "SocketIO.objc"
  s.version      = "0.0.1"
  s.summary      = "A short description of SocketIO.objc."

  s.description  = <<-DESC
                   A longer description of SocketIO.objc in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://github.com/hden/socketio.objc"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author                = { "Hao-kang Den" => "haokang.den@gmail.com" }
  s.social_media_url      = "http://twitter.com/_hden"
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"

  s.source       = { :git => "https://github.com/hden/socketio.objc.git", :tag => "0.0.1" }
  s.source_files = "SocketIO.objc/**/*.{h,m}"
  s.requires_arc = true

  s.public_header_files = "SocketIO.objc/**/*.h"
  s.dependency 'SocketRocket', '~> 0.3'
  s.dependency 'socket.IO', '~> 0.5'
  s.dependency 'Emitter', '~> 0.0'
end
