Pod::Spec.new do |s|
  s.name = "Charts"
  s.version = "4.0.3"
  s.summary = "Charts is a powerful & easy to use chart library for iOS, tvOS and OSX (and Android)"
  s.homepage = "https://github.com/danielgindi/Charts"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = "Daniel Cohen Gindi", "Philipp Jahoda"
  s.ios.deployment_target = "12.0"
  s.tvos.deployment_target = "12.0"
  s.osx.deployment_target = "10.12"
  s.source = { :git => "https://github.com/danielgindi/Charts.git", :tag => "v#{s.version}" }
  s.default_subspec = "Core"
  s.swift_version = '5.3'
  s.cocoapods_version = '>= 1.5.0'
  
  s.subspec "Core" do |ss|
    ss.source_files  = "Source/Charts/**/*.swift"
    ss.dependency 'SwiftAlgorithms', '~> 1.0'
  end
end
