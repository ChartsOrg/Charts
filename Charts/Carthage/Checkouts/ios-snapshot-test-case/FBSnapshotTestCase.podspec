Pod::Spec.new do |s|
  s.name         = "FBSnapshotTestCase"
  s.version      = "2.0.5"
  s.summary      = "Snapshot view unit tests for iOS"
  s.description  = <<-DESC
                    A "snapshot test case" takes a configured UIView or CALayer
                    and uses the renderInContext: method to get an image snapshot
                    of its contents. It compares this snapshot to a "reference image"
                    stored in your source code repository and fails the test if the
                    two images don't match.
                   DESC
  s.homepage     = "https://github.com/facebook/ios-snapshot-test-case"
  s.license      = 'BSD'
  s.author       = 'Facebook'
  s.source       = { :git => "https://github.com/facebook/ios-snapshot-test-case.git",
                     :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.framework    = 'XCTest'
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
  s.public_header_files = ['FBSnapshotTestCase/FBSnapshotTestCase.h', 'FBSnapshotTestCase/FBSnapshotTestCasePlatform.h']
  s.private_header_files = ['FBSnapshotTestCase/FBSnapshotTestController.h', 'FBSnapshotTestCase/UIImage+Compare.h', 'FBSnapshotTestCase/UIImage+Diff.h']
  s.default_subspecs = 'SwiftSupport'
  s.subspec 'Core' do |cs|
    cs.source_files = 'FBSnapshotTestCase/**/*.{h,m}'
  end
  s.subspec 'SwiftSupport' do |cs|
    cs.dependency 'FBSnapshotTestCase/Core'
    cs.source_files = 'FBSnapshotTestCase/**/*.swift'
  end
end
