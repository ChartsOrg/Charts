Pod::Spec.new do |s|
  s.name = "Charts"
  s.version = "4.0.3.1"
  s.summary = "Fork of Charts by Daniel Cohen Gindi"
  s.homepage = "https://github.com/danielgindi/Charts"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = "Daniel Cohen Gindi", "Philipp Jahoda"
  s.ios.deployment_target = "11.0"
  s.source = { :git => "https://github.com/Objectway/Charts.git", :tag => "#{s.version}" }
  s.default_subspec = "Core"
  s.swift_version = '5.0'
  s.cocoapods_version = '>= 1.5.0'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  s.subspec "Core" do |ss|
    ss.source_files  = "Source/Charts/**/*.swift"
  end
end
