rm -Rf "archive"

xcodebuild archive -scheme "Charts"\
    -archivePath "archive/Charts-iOS Simulator.xcarchive"\
    -destination "generic/platform=iOS Simulator"\
    SKIP_INSTALL=NO

xcodebuild archive -scheme "Charts"\
    -archivePath "archive/Charts-iOS.xcarchive"\
    -destination "generic/platform=iOS"\
    SKIP_INSTALL=NO

xcodebuild archive -scheme "Charts"\
    -archivePath "archive/Charts-macOS.xcarchive"\
    -destination "platform=macOS,arch=x86_64"\
    SKIP_INSTALL=NO

rm -Rf "Charts.xcframework"

xcodebuild -create-xcframework\
    -framework "archive/Charts-iOS Simulator.xcarchive/Products/Library/Frameworks/Charts.framework"\
    -framework "archive/Charts-iOS.xcarchive/Products/Library/Frameworks/Charts.framework"\
    -framework "archive/Charts-macOS.xcarchive/Products/Library/Frameworks/Charts.framework"\
    -output "Charts.xcframework"

tar -czv -f Charts.xcframework.tar.gz Charts.xcframework
