
Pod::Spec.new do |s|
  s.name         = "Nakama"
  s.version      = "0.3.0"
  s.summary      = "Swift client for Nakama server."
  s.description  = <<-DESC
  The official Swift client handles all communication in realtime with the server and is specifically optimized for iOS projects. It implements all features in the server and is compatible with Swift 3.1+.
                   DESC
  s.homepage     = "https://heroiclabs.com/docs/swift-ios-client-guide/"
  s.license      = 'Apache License, Version 2.0'

  s.author             = { "Heroic Labs" => "support@heroiclabs.com" }
  s.social_media_url   = "https://twitter.com/heroicdev"

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/heroiclabs/nakama-swift.git", :tag => "v#{s.version}" }
  s.source_files  = "Sources/Nakama/*.{h,m,swift}"

  s.dependency "SwiftProtobuf", "~> 1"
  s.dependency "Starscream", "~> 2"
  s.dependency "PromiseKit", "~> 6"

end
