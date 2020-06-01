Pod::Spec.new do |s|
  s.name             = "DaggerSwift"
  s.version          = "0.0.2"
  s.summary          = "Simple library to connect with dagger server and manage subscriptions for Ethereum Blockchain."
 
  s.description      = <<-DESC
DaggerSwift is library for dagger project written in swift. It uses dagger server to get realtime updates from Ethereum Network.
                       DESC
 
  s.homepage         = "https://github.com/maticnetwork/dagger-swift-sdk"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Matic" => "team.wallet@matic.network" }
  s.source           = { :git => "https://github.com/maticnetwork/dagger-swift-sdk.git", :tag => s.version.to_s }
 
  s.ios.deployment_target = "11.0"
  s.swift_version = "5.1"
  s.source_files = "Sources/Dagger/**/*"
  s.dependency "SwiftMQTT"
end