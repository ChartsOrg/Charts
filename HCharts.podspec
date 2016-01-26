Pod::Spec.new do |s|
  s.name = "HCharts"
  s.version = "2.1.7"
  s.summary = "ios-charts is a powerful & easy to use chart library for iOS"
  s.homepage = "https://github.com/anthony0926/ios-charts"
  s.license = 'MIT'
  s.authors = "Daniel Cohen Gindi", "Philipp Jahoda"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.source = { :git => "https://github.com/anthony0926/ios-charts.git", :commit => "fcf75f9817c1313de1f83c156c80a6cae850d15d" }
  s.source_files = "Classes", "Charts/Classes/**/*.swift"
end
