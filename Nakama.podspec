
Pod::Spec.new do |s|
  s.name         = "Nakama"
  s.version      = "3.0.114"
  s.summary      = "Swift client for Nakama server."
  s.description  = <<-DESC
  Swift client for Nakama server.
                   DESC
  s.homepage     = "https://heroiclabs.com/docs/swift-ios-client-guide/"
  s.license      = 'Apache License, Version 2.0'

  s.author             = { "Heroic Labs" => "support@heroiclabs.com" }
  s.social_media_url   = "https://twitter.com/heroicdev"

  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.13"
  s.tvos.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/Allan-Nava/nakama-swift.git", :tag => "v#{s.version}" }
  s.source_files  = "Sources/Nakama/*.{h,m,swift}"

  s.dependency "Starscream", ">= 3.1.1"
  s.dependency 'SwiftNIO', '>= 2.26.0', '< 3'
  s.dependency 'SwiftNIOSSL', '>= 2.10.4', '< 3'
  s.dependency 'SwiftNIOTransportServices', '>= 1.9.1', '< 2'
  s.dependency 'SwiftProtobuf', '>= 1.14.0', '< 2'
  s.dependency "gRPC-Swift", '>= 1.0.0', '< 2'
  s.dependency "PromiseKit", '>= 6.13.0', '< 7'

end
