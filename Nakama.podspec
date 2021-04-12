
Pod::Spec.new do |s|
  s.name         = "Nakama"
  s.version      = "3.0.0"
  s.summary      = "Swift client for Nakama server."
  s.description  = <<-DESC
  Swift client for Nakama server.
                   DESC
  s.homepage     = "https://heroiclabs.com/docs/swift-ios-client-guide/"
  s.license      = 'Apache License, Version 2.0'

  s.author             = { "Heroic Labs" => "support@heroiclabs.com" }
  s.social_media_url   = "https://twitter.com/heroicdev"

  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  s.tvos.deployment_target = "13.0"
  s.watchos.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/heroiclabs/nakama-swift.git", :tag => "v#{s.version}" }
  s.source_files  = "Sources/Nakama/*.{h,m,swift}"

  s.dependency 'SwiftNIO', '>= 2.25.0', '< 3'
  s.dependency 'SwiftNIOSSL', '>= 2.10.1', '< 3'
  s.dependency 'SwiftNIOTransportServices', '>= 1.9.1', '< 2'
  s.dependency 'SwiftProtobuf', '>= 1.13.0', '< 2'
  s.dependency "gRPC-Swift", '>= 1.0.0-alpha.22', '< 2'
  s.dependency "PromiseKit", '>= 6', '< 7'
  s.dependency "SwiftAtomics", '>= 0.0.2', '< 0.0.2'
end
