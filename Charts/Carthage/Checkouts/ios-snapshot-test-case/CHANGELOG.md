# Change Log

All notable changes to this project will be documented in this file.

## 2.0.5

  - Swift 2.0 (#111, #120) (Thanks to @pietbrauer and @grantjk)
  - Fix pod spec by disabling bitcode (#115) (Thanks to @soleares)
  - Fix for incorrect errors with multiple suffixes (#119) (Thanks to @Grubas7)
  - Support for Model and OS in image names (#121 thanks to @esttorhe)

## 2.0.4

  - Support loading reference images from the test bundle (#104) (Thanks to @yiding)
  - Fix for retina tolerance comparisons (#107)

## 2.0.3

  - New property added `usesDrawViewHierarchyInRect` to handle cases like `UIVisualEffect` (#70), `UIAppearance` (#91) and Size Classes (#92) (#100)

## 2.0.2

  - Fix for retina comparisons (#96) 
  
## 2.0.1

  - Allow usage of Objective-C subspec only, for projects supporting iOS 7 (#93) (Thanks to @x2on)

## 2.0.0

  - Approximate comparison (#88) (Thanks to @nap-sam-dean)
  - Swift support (#87) (Thanks to @pietbrauer)

## 1.8.1

### Fixed

  - Prevent mangling of C function names when compiled with a C++ compiler. (#79)

## 1.8.0

### Changed

  - The default directories for snapshots images are now **ReferenceImages_32** (32bit) and **ReferenceImages_64** (64bit) and the suffix depends on the architecture when the test is running. (#77) 
  	- If a test fails for a given suffix, it will try to load and compare all other suffixes before failing.
  - Added assertion on setRecordMode. (#76)
