Pod::Spec.new do |s|
  s.name = "Charts"
  s.version = "2.2.3"
  s.summary = "ios-charts is a powerful & easy to use chart library for iOS, tvOS and OSX"
  s.homepage = "https://github.com/danielgindi/ios-charts"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = "Daniel Cohen Gindi", "Philipp Jahoda"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.source = { :git => "https://github.com/danielgindi/ios-charts.git", :tag => "v#{s.version}" }
  s.default_subspec = "Core"
  s.prepare_command = "sed -i '' -e 's/import Charts//g' ChartsRealm/Classes/**/*.swift"

  s.subspec "Core" do |ss|
    ss.source_files  = "Charts/Classes/**/*.swift"
  end

  s.subspec "Realm" do |ss|
    ss.source_files  = "ChartsRealm/Classes/**/*.swift"
    ss.dependency "Charts/Core"
    ss.dependency "RealmSwift", "~> 0.97"
  end
end
