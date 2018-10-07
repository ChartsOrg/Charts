#!/bin/bash

# Script configuration

ios_devices=(
	"iPhone 5s"
	"iPhone 8"
	"iPhone 8 Plus"
	"iPhone X"
	"iPhone XR"
	"iPhone XS Max"
	"iPad Pro (9.7-inch)"
	"iPad Pro (10.5-inch)"
	"iPad Pro (12.9-inch)"
	)
tvos_devices=(
	"Apple TV 4K (at 1080p)"
)
workspace="../Charts"

scheme="ChartsTests"

# List devices to snapshot

echo "Devices to snapshot:"
for index in ${!ios_devices[*]}
do
    printf "   %s\n" "${ios_devices[$index]}"
done

for index in ${!tvos_devices[*]}
do
    printf "   %s\n" "${tvos_devices[$index]}"
done

# Create and run command

baseCommand="xcodebuild test -workspace $workspace.xcworkspace -scheme $scheme" 

for index in ${!ios_devices[*]}
do
    eval "$baseCommand -destination 'platform=iOS Simulator,name=${ios_devices[$index]}'"
done

for index in ${!tvos_devices[*]}
do
    eval "$baseCommand -destination 'platform=tvOS Simulator,name=${tvos_devices[$index]}'"
done
