Pod::Spec.new do |s|
  s.name = "Charts"
  s.version = "2.1.6"
  s.summary = "ios-charts is a powerful & easy to use chart library for iOS"
  s.homepage = "https://github.com/danielgindi/ios-charts"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = "Daniel Cohen Gindi", "Philipp Jahoda"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.source = { :git => "https://github.com/danielgindi/ios-charts.git", :tag => "v#{s.version}" }
  s.source_files = "Classes", "Charts/Classes/**/*.swift"
end
