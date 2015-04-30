**Version 2.0.9**, synced to [MPAndroidChart #aa7cbce](https://github.com/PhilJay/MPAndroidChart/commit/aa7cbce0330de983dac26bf0cda3a23b46b4df1d)

![alt tag](https://raw.github.com/danielgindi/ios-charts/master/Assets/feature_graphic.png)

**Requirements:**  
* Xcode 6.3 / Swift 1.2
* iOS 7.0 (Drag .swift files to your project)
* iOS 8.0 (Use as a Framework)

Okay so there's this beautiful library called [MPAndroidChart](https://github.com/PhilJay/MPAndroidChart) by [Philipp Jahoda](https://www.linkedin.com/in/philippjahoda) which has become very popular amongst Android developers, and in the meanwhile there's no decent charting solution for iOS.

I've chosen to write it in `Swift` as it can be highly optimized by the compiler, and can be used in both `Swift` and `ObjC` project. The demo project is written in `ObjC` to demonstrate how it works.

**An amazing feature** of this library now, both Android and iOS, is the time it saves you when developing for both platforms, as the learning curve is singleton- it happens only once, and the code stays very similar so developers don't have to go around and re-invent the app to produce the same output with a different library. (And that's not even considering the fact that there's not really another good choice out there currently...)

## Usage

In order to correctly compile:

1. Drag the `Charts.xcodeproj` to your project  
2. Go to your target's settings, hit the "+" under the "Embedded Binaries" section, and select the Charts.framework  
3. `@import Charts`  
4.  When using Swift in an ObjC project, you need to import your Bridging Header. Usually it is "*YourProject-Swift.h*", so in ChartsDemo it's "*ChartsDemo-Swift.h*". Do not try to actually include "*ChartsDemo-Swift.h*" in your project :-)

If you want to compile for iOS 7, then you just need to drag the code itself (.swift files) to your project. As sadly, Swift currently does not support compiling Frameworks for iOS 7.

## Help

If you like what you see here, and want to support the work being done in this repository, you could:
* Contribute code, issues and pull requests
* Let people know this library exists (spread the word!)
* 
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CHRDHZE79YTMQ) (As much or as little as you like/can.)

**Note:** The author of [MPAndroidChart](https://github.com/PhilJay/MPAndroidChart) is the reason that this library exists, and is accepting [donations](https://github.com/PhilJay/MPAndroidChart#donations) on his page. He deserves them!

Questions & Issues
-----

If you are having questions or problems, you should:

 - Make sure you are using the latest version of the library. Check the [**release-section**](https://github.com/danielgindi/ios-charts/releases).
 - Study the [**Documentation-Wiki**](https://github.com/PhilJay/MPAndroidChart/wiki)
 - Search or open questions on [**stackoverflow**](http://stackoverflow.com/questions/tagged/ios-charts) with the `ios-charts` tag
 - Search [**known issues**](https://github.com/danielgindi/ios-charts/issues) for your problem (open and closed)
 - Create new issues (please **search known issues before**, do not create duplicate issues)


Features
=======

**Core features:**
 - Scaling on both axes (with touch-gesture, axes separately or pinch-zoom)
 - Dragging / Panning (with touch-gesture)
 - Combined-Charts (line-, bar-, scatter-, candle-data)
 - Dual (separate) Y-Axis
 - Finger drawing (draw values into the chart with touch-gesture)
 - Highlighting values (with customizeable popup-views)
 - Multiple / Separate Axes
 - Save chart to camera-roll
 - Predefined color templates
 - Legends (generated automatically, customizeable)
 - Customizeable Axes (both x- and y-axis)
 - Animations (build up animations, on both x- and y-axis)
 - Limit lines (providing additional information, maximums, ...)
 - Fully customizeable (paints, typefaces, legends, colors, background, gestures, dashed lines, ...)
 
**Chart types:**

*Screenshots are currently taken from the original repository, as they render exactly the same :-)*

 - **LineChart (with legend, simple design)**
![alt tag](https://raw.github.com/PhilJay/MPChart/master/screenshots/simpledesign_linechart4.png)
 - **LineChart (with legend, simple design)**
![alt tag](https://raw.github.com/PhilJay/MPChart/master/screenshots/simpledesign_linechart3.png)

 - **LineChart (cubic lines)**
![alt tag](https://raw.github.com/PhilJay/MPChart/master/screenshots/cubiclinechart.png)

 - **LineChart (single DataSet)**
![alt tag](https://raw.github.com/PhilJay/MPChart/master/screenshots/linechart.png)

 - **Combined-Chart (bar- and linechart in this case)**
![alt tag](https://raw.github.com/PhilJay/MPChart/master/screenshots/combined_chart.png)

 - **BarChart (with legend, simple design)**

![alt tag](https://raw.github.com/PhilJay/MPChart/master/screenshots/simpledesign_barchart3.png)

 - **BarChart (grouped DataSets)**

![alt tag](https://raw.github.com/PhilJay/MPChart/master/screenshots/groupedbarchart.png)

 - **Horizontal-BarChart**

![alt tag](https://raw.github.com/PhilJay/MPChart/master/screenshots/horizontal_barchart.jpg)


 - **PieChart (with selection, ...)**

![alt tag](https://raw.github.com/PhilJay/MPAndroidChart/master/screenshots/simpledesign_piechart1.png)

 - **ScatterChart** (with squares, triangles, circles, ... and more)

![alt tag](https://raw.github.com/PhilJay/MPAndroidChart/master/screenshots/scatterchart.png)

 - **CandleStickChart** (for financial data)

![alt tag](https://raw.github.com/PhilJay/MPAndroidChart/master/screenshots/candlestickchart.png)

 - **RadarChart** (spider web chart)

![alt tag](https://raw.github.com/PhilJay/MPAndroidChart/master/screenshots/radarchart.png)


Documentation
=======
Currently there's no need for documentation for the iOS version, as the API is **95% the same** as on Android.  
You can read the official [MPAndroidChart](https://github.com/PhilJay/MPAndroidChart) documentation here: [**Wiki**](https://github.com/PhilJay/MPAndroidChart/wiki)

Or you can see the [**ChartsDemo**](https://github.com/danielgindi/ios-charts/tree/master/ChartsDemo) project and learn the how-tos from it.


Special Thanks
=======

Goes to @petester42 (Pierre-Marc Airoldi) for implementing a Bubble chart!  
And of course thanks to all of those contibuting small fixes here and there! You are all appreciated!

License
=======
Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
