# Changelog

## [v3.5.0](https://github.com/danielgindi/Charts/tree/v3.5.0) (2020-04-16)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.4.0...v3.5.0)

**Merged pull requests:**

- Fix warnings on current code base [\#4321](https://github.com/danielgindi/Charts/pull/4321) ([liuxuan30](https://github.com/liuxuan30))
- Bugfix/legend offset double [\#4277](https://github.com/danielgindi/Charts/pull/4277) ([danielgindi](https://github.com/danielgindi))
- Fix for \#4274 string comparison issue in ChartData::getDataSetByLabel [\#4275](https://github.com/danielgindi/Charts/pull/4275) ([PeterKaminski09](https://github.com/PeterKaminski09))
- Restored correct velocity sampler [\#4273](https://github.com/danielgindi/Charts/pull/4273) ([danielgindi](https://github.com/danielgindi))
- Bugfix/pie highlight [\#4272](https://github.com/danielgindi/Charts/pull/4272) ([danielgindi](https://github.com/danielgindi))
- Call chartViewDidEndPanning on when \*panning\* is ended [\#4271](https://github.com/danielgindi/Charts/pull/4271) ([danielgindi](https://github.com/danielgindi))
- labelXOffset = 10 is default for radar chart only [\#4270](https://github.com/danielgindi/Charts/pull/4270) ([danielgindi](https://github.com/danielgindi))
- Use faster check for line whether it's inside drawing rect [\#4269](https://github.com/danielgindi/Charts/pull/4269) ([danielgindi](https://github.com/danielgindi))
- Refactor/cleanup [\#4268](https://github.com/danielgindi/Charts/pull/4268) ([danielgindi](https://github.com/danielgindi))
- address \#4033 draw half pie chart more accurate [\#4266](https://github.com/danielgindi/Charts/pull/4266) ([liuxuan30](https://github.com/liuxuan30))
- Update README.md, added link to tutorial about Radar Charts. [\#4258](https://github.com/danielgindi/Charts/pull/4258) ([DavidPiper94](https://github.com/DavidPiper94))
- Changes to fix Catalyst compatibility [\#4254](https://github.com/danielgindi/Charts/pull/4254) ([CAPIStkidd](https://github.com/CAPIStkidd))
- Platform separation [\#4178](https://github.com/danielgindi/Charts/pull/4178) ([jjatie](https://github.com/jjatie))
- introduce gracefully degrading abstractions for dark mode for ios and… [\#4171](https://github.com/danielgindi/Charts/pull/4171) ([motocodeltd](https://github.com/motocodeltd))
- Performed recommended localization and internationalization changes. [\#4162](https://github.com/danielgindi/Charts/pull/4162) ([coltonlemmon](https://github.com/coltonlemmon))
- Use interpolation instead of '+' concatenation for problematic expression [\#4123](https://github.com/danielgindi/Charts/pull/4123) ([Jumhyn](https://github.com/Jumhyn))
- Allowing overriding for YAxisRenderer.drawYLabels [\#4089](https://github.com/danielgindi/Charts/pull/4089) ([muclemente](https://github.com/muclemente))
- move isDrawCirclesEnabled check further up in code to avoid creating … [\#4050](https://github.com/danielgindi/Charts/pull/4050) ([xymtek](https://github.com/xymtek))

## [v3.4.0](https://github.com/danielgindi/Charts/tree/v3.4.0) (2019-10-09)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.3.0...v3.4.0)

**Merged pull requests:**

- Apply Xcode11 changes [\#4153](https://github.com/danielgindi/Charts/pull/4153) ([liuxuan30](https://github.com/liuxuan30))
- Fixes \#4099: Line renderer did not render lines if their coordinates fell outside of the viewport. [\#4100](https://github.com/danielgindi/Charts/pull/4100) ([4np](https://github.com/4np))
- Fix line chart x axis animation \#4093, also close \#3960 [\#4094](https://github.com/danielgindi/Charts/pull/4094) ([liuxuan30](https://github.com/liuxuan30))
- Update License [\#4055](https://github.com/danielgindi/Charts/pull/4055) ([jobinsjohn](https://github.com/jobinsjohn))
- fixed stacked chart bug when there are different stacks on columns. [\#4029](https://github.com/danielgindi/Charts/pull/4029) ([Scalman](https://github.com/Scalman))
- Fix Swift Package Manager compile issue [\#4017](https://github.com/danielgindi/Charts/pull/4017) ([rynecheow](https://github.com/rynecheow))
- Added a safety check before an unsafe array operation [\#4006](https://github.com/danielgindi/Charts/pull/4006) ([UberNick](https://github.com/UberNick))
- fix \#3975 \(pie chart highlight disabled will lead to empty slice\) [\#3996](https://github.com/danielgindi/Charts/pull/3996) ([liuxuan30](https://github.com/liuxuan30))
- For \#3917. make init\(label: String?\) convenient initializer [\#3973](https://github.com/danielgindi/Charts/pull/3973) ([liuxuan30](https://github.com/liuxuan30))
- Avoid passing NaN to CoreGraphics API \(Fixes \#1626\) [\#2568](https://github.com/danielgindi/Charts/pull/2568) ([chiahan1123](https://github.com/chiahan1123))

## [v3.3.0](https://github.com/danielgindi/Charts/tree/v3.3.0) (2019-04-24)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.2.2...v3.3.0)

**Implemented enhancements:**

- Renamed `values` to `entries` to reflect the property's type [\#3847](https://github.com/danielgindi/Charts/pull/3847) ([jjatie](https://github.com/jjatie))

**Merged pull requests:**

- Fix horizontal bar chart not drawing values and add unit tests [\#3906](https://github.com/danielgindi/Charts/pull/3906) ([liuxuan30](https://github.com/liuxuan30))
- fix \#3860. maxHeight didn't count the last label [\#3900](https://github.com/danielgindi/Charts/pull/3900) ([liuxuan30](https://github.com/liuxuan30))
- Migrating to built-in algorithms [\#3892](https://github.com/danielgindi/Charts/pull/3892) ([jjatie](https://github.com/jjatie))
- Use a stock iterator instead of a custom one. [\#3891](https://github.com/danielgindi/Charts/pull/3891) ([phughes](https://github.com/phughes))
- Removed unnecessary \#if statements and unified style to align with Xc… [\#3884](https://github.com/danielgindi/Charts/pull/3884) ([jjatie](https://github.com/jjatie))
- Velocity samples calculation [\#3883](https://github.com/danielgindi/Charts/pull/3883) ([jjatie](https://github.com/jjatie))
- Minor updates for Swift 5 [\#3874](https://github.com/danielgindi/Charts/pull/3874) ([jjatie](https://github.com/jjatie))
- Replace AnyObject with Any [\#3864](https://github.com/danielgindi/Charts/pull/3864) ([jjatie](https://github.com/jjatie))
- Data as any [\#3863](https://github.com/danielgindi/Charts/pull/3863) ([jjatie](https://github.com/jjatie))
- Reassess convenience initializers [\#3862](https://github.com/danielgindi/Charts/pull/3862) ([jjatie](https://github.com/jjatie))
- HorizontalBarChar value label offset calculation  [\#3854](https://github.com/danielgindi/Charts/pull/3854) ([chaaarly](https://github.com/chaaarly))
- Create `chartViewDidEndAnimate` in ChartViewDelegate [\#3852](https://github.com/danielgindi/Charts/pull/3852) ([Lcsmarcal](https://github.com/Lcsmarcal))
- Align `ChartLimit.LabelPosition` naming with `UIRectCorner` [\#3846](https://github.com/danielgindi/Charts/pull/3846) ([jjatie](https://github.com/jjatie))

## [v3.2.2](https://github.com/danielgindi/Charts/tree/v3.2.2) (2019-02-13)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.2.1...v3.2.2)

**Merged pull requests:**

- Add Collection conformances to ChartDataSet types [\#3815](https://github.com/danielgindi/Charts/pull/3815) ([jjatie](https://github.com/jjatie))
- Fix condition that is checked before `chartTranslated` delegate method call [\#3804](https://github.com/danielgindi/Charts/pull/3804) ([anton-filimonov](https://github.com/anton-filimonov))
- fix \#3719 [\#3778](https://github.com/danielgindi/Charts/pull/3778) ([liuxuan30](https://github.com/liuxuan30))
- add chartScaled\(\) call after double tap in BarLineChartViewBase [\#3770](https://github.com/danielgindi/Charts/pull/3770) ([artemiusmk](https://github.com/artemiusmk))
- Fixes sharp edges on the line chart [\#3764](https://github.com/danielgindi/Charts/pull/3764) ([stokatyan](https://github.com/stokatyan))
- Fix applying lineCap value for line chart data sets \(Fixes \#3739\) [\#3740](https://github.com/danielgindi/Charts/pull/3740) ([anton-filimonov](https://github.com/anton-filimonov))
- Update README.md [\#3737](https://github.com/danielgindi/Charts/pull/3737) ([justinlew](https://github.com/justinlew))
- Fix legend offset bug for horizontal bar chart \(Fixes \#3301\) [\#3736](https://github.com/danielgindi/Charts/pull/3736) ([SvenMuc](https://github.com/SvenMuc))
- Fix wrong assignment to axisMaxLabels property [\#3721](https://github.com/danielgindi/Charts/pull/3721) ([ggirotto](https://github.com/ggirotto))
- Add missing properties to copy\(with:\) methods [\#3715](https://github.com/danielgindi/Charts/pull/3715) ([dstranz](https://github.com/dstranz))
- Multiple colors for valueline \(Fixes \#3480\) [\#3709](https://github.com/danielgindi/Charts/pull/3709) ([AlexeiGitH](https://github.com/AlexeiGitH))
- Fix memory leak after rendering [\#3680](https://github.com/danielgindi/Charts/pull/3680) ([YusukeOba](https://github.com/YusukeOba))
- fix issue \#3662 [\#3664](https://github.com/danielgindi/Charts/pull/3664) ([Michael-Du](https://github.com/Michael-Du))
- Make NSUIAccessibilityElement initializer public. [\#3654](https://github.com/danielgindi/Charts/pull/3654) ([417-72KI](https://github.com/417-72KI))
- improvements in barRect height calculation  [\#3650](https://github.com/danielgindi/Charts/pull/3650) ([potato04](https://github.com/potato04))
- Update document to latest format [\#3621](https://github.com/danielgindi/Charts/pull/3621) ([kemchenj](https://github.com/kemchenj))
- Feature - ChartView Pan Ended Delegate Call [\#3612](https://github.com/danielgindi/Charts/pull/3612) ([AntonTheDev](https://github.com/AntonTheDev))

## [v3.2.1](https://github.com/danielgindi/Charts/tree/v3.2.1) (2018-10-08)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.2.0...v3.2.1)

## [v3.2.0](https://github.com/danielgindi/Charts/tree/v3.2.0) (2018-09-17)

[Full Changelog](https://github.com/danielgindi/Charts/compare/3.1.1...v3.2.0)

**Merged pull requests:**

- update barRect.size.height calculation [\#3587](https://github.com/danielgindi/Charts/pull/3587) ([potato04](https://github.com/potato04))
- Support inlune bubble viz selection [\#3548](https://github.com/danielgindi/Charts/pull/3548) ([chuynadamas](https://github.com/chuynadamas))
- fix the error title for demo [\#3528](https://github.com/danielgindi/Charts/pull/3528) ([yangasahi](https://github.com/yangasahi))
- Changes for Swift 4.2, Xcode 10 and iOS 12 [\#3522](https://github.com/danielgindi/Charts/pull/3522) ([jlcanale](https://github.com/jlcanale))
- Accessibility Support for \(most\) Chart types [\#3520](https://github.com/danielgindi/Charts/pull/3520) ([mathewa6](https://github.com/mathewa6))
- Changed comment that referenced getFormattedValue\(\) method in IValueFormatter [\#3518](https://github.com/danielgindi/Charts/pull/3518) ([JCMcLovin](https://github.com/JCMcLovin))
- Fix broken demo link in readme [\#3440](https://github.com/danielgindi/Charts/pull/3440) ([robert-cronin](https://github.com/robert-cronin))
- Added clamping function for `Comparable` [\#3435](https://github.com/danielgindi/Charts/pull/3435) ([jjatie](https://github.com/jjatie))
- update candle chart view options in demo project [\#3424](https://github.com/danielgindi/Charts/pull/3424) ([cuong1112035](https://github.com/cuong1112035))
- Add Objective-c compatible for turning off drag in X and Y Axis separately [\#3421](https://github.com/danielgindi/Charts/pull/3421) ([lennonhe](https://github.com/lennonhe))
- Add more render options for y axis labels [\#3406](https://github.com/danielgindi/Charts/pull/3406) ([alexrepty](https://github.com/alexrepty))

## [3.1.1](https://github.com/danielgindi/Charts/tree/3.1.1) (2018-04-02)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.1.1...3.1.1)

## [v3.1.1](https://github.com/danielgindi/Charts/tree/v3.1.1) (2018-04-02)

[Full Changelog](https://github.com/danielgindi/Charts/compare/3.1.0...v3.1.1)

**Merged pull requests:**

- Swift 4.1 [\#3370](https://github.com/danielgindi/Charts/pull/3370) ([jjatie](https://github.com/jjatie))
- Update ILineRadarChartDataSet.swift [\#3366](https://github.com/danielgindi/Charts/pull/3366) ([Ewg777](https://github.com/Ewg777))
- Add option to disable clipping data to contentRect [\#3360](https://github.com/danielgindi/Charts/pull/3360) ([wtmoose](https://github.com/wtmoose))

## [3.1.0](https://github.com/danielgindi/Charts/tree/3.1.0) (2018-03-22)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.1.0...3.1.0)

## [v3.1.0](https://github.com/danielgindi/Charts/tree/v3.1.0) (2018-03-22)

[Full Changelog](https://github.com/danielgindi/Charts/compare/3.0.5...v3.1.0)

**Merged pull requests:**

- bump to 3.1 release [\#3357](https://github.com/danielgindi/Charts/pull/3357) ([liuxuan30](https://github.com/liuxuan30))
- Refactors -\[tableView:cellForRowAtIndexPath:\] [\#3326](https://github.com/danielgindi/Charts/pull/3326) ([valeriyvan](https://github.com/valeriyvan))
- minor bug fix in favor of 3.1 release [\#3312](https://github.com/danielgindi/Charts/pull/3312) ([liuxuan30](https://github.com/liuxuan30))
- add pie chart unit tests [\#3297](https://github.com/danielgindi/Charts/pull/3297) ([liuxuan30](https://github.com/liuxuan30))
- Align Objc and Swift demos balloon marker [\#3291](https://github.com/danielgindi/Charts/pull/3291) ([liuxuan30](https://github.com/liuxuan30))
- for \#3146. add a warning message if pie chart has more than one data set [\#3286](https://github.com/danielgindi/Charts/pull/3286) ([liuxuan30](https://github.com/liuxuan30))
- Issue templates [\#3278](https://github.com/danielgindi/Charts/pull/3278) ([jjatie](https://github.com/jjatie))
- Min and Max reset when clearing ChartDataSet \(Fixes \#3260\) [\#3265](https://github.com/danielgindi/Charts/pull/3265) ([carlo-](https://github.com/carlo-))
- Restored old performance in ChartDataSet [\#3216](https://github.com/danielgindi/Charts/pull/3216) ([jjatie](https://github.com/jjatie))
- Support other bundle than main MarkerView.viewFromXib\(\) [\#3215](https://github.com/danielgindi/Charts/pull/3215) ([charlymr](https://github.com/charlymr))
- BubbleChart uses correct colour for index now. [\#3202](https://github.com/danielgindi/Charts/pull/3202) ([jjatie](https://github.com/jjatie))
- Added custom text alignment for noData [\#3199](https://github.com/danielgindi/Charts/pull/3199) ([jjatie](https://github.com/jjatie))
- Call setNeedsDisplay\(\) to trigger render noDataText [\#3198](https://github.com/danielgindi/Charts/pull/3198) ([liuxuan30](https://github.com/liuxuan30))
- Updated README for 3.0.5 [\#3183](https://github.com/danielgindi/Charts/pull/3183) ([jjatie](https://github.com/jjatie))
- Balloon Marker indicates position of data [\#3181](https://github.com/danielgindi/Charts/pull/3181) ([jjatie](https://github.com/jjatie))
- Fixed a duplicated assignment compared with obj-c code. [\#3179](https://github.com/danielgindi/Charts/pull/3179) ([canapio](https://github.com/canapio))
- Fixed X-Axis Labels Not Showing \(\#3154\) [\#3174](https://github.com/danielgindi/Charts/pull/3174) ([leedsalex](https://github.com/leedsalex))
- fix programatical unhighlighting for BarCharView [\#3159](https://github.com/danielgindi/Charts/pull/3159) ([jekahy](https://github.com/jekahy))
- Fix BalloonMarker's text position calculation, consider insets [\#3035](https://github.com/danielgindi/Charts/pull/3035) ([yangcaimu](https://github.com/yangcaimu))
- Give the users customizable axis label limits \(Fixes \#2085\) [\#2894](https://github.com/danielgindi/Charts/pull/2894) ([igzrobertoestrada](https://github.com/igzrobertoestrada))
- For \#2840. add dataIndex parameter in `highlightValue\(\)` calls [\#2852](https://github.com/danielgindi/Charts/pull/2852) ([liuxuan30](https://github.com/liuxuan30))
- fix \#2356 crash if floor\(10.0 \* intervalMagnitude\) is 0.0 [\#2377](https://github.com/danielgindi/Charts/pull/2377) ([liuxuan30](https://github.com/liuxuan30))
- Fixes the distance issue between the legend and the horizontal bar chart \(Fixes \#2138\) [\#2214](https://github.com/danielgindi/Charts/pull/2214) ([SvenMuc](https://github.com/SvenMuc))

## [3.0.5](https://github.com/danielgindi/Charts/tree/3.0.5) (2018-01-08)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.0.5...3.0.5)

## [v3.0.5](https://github.com/danielgindi/Charts/tree/v3.0.5) (2018-01-08)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.0.4...v3.0.5)

**Merged pull requests:**

- Subclassing of LegendRenderer didn't take any effect [\#3149](https://github.com/danielgindi/Charts/pull/3149) ([l-lemesev](https://github.com/l-lemesev))
- Update ViewPortHandler.swift [\#3143](https://github.com/danielgindi/Charts/pull/3143) ([ParkinWu](https://github.com/ParkinWu))
- Update 4.0.0 with master [\#3135](https://github.com/danielgindi/Charts/pull/3135) ([jjatie](https://github.com/jjatie))
- Fix axis label disappear when zooming in deep enough [\#3132](https://github.com/danielgindi/Charts/pull/3132) ([liuxuan30](https://github.com/liuxuan30))
- add option to build demo projects unit tests on iOS [\#3121](https://github.com/danielgindi/Charts/pull/3121) ([liuxuan30](https://github.com/liuxuan30))
- Makes ChartsDemo compiling again [\#3117](https://github.com/danielgindi/Charts/pull/3117) ([valeriyvan](https://github.com/valeriyvan))
- Fixed using wrong axis \(Issue \#2257\) [\#3114](https://github.com/danielgindi/Charts/pull/3114) ([defranke](https://github.com/defranke))
- for \#3061 fix animation crash [\#3098](https://github.com/danielgindi/Charts/pull/3098) ([liuxuan30](https://github.com/liuxuan30))
- Refactored ChartUtils method into CGPoint extension [\#3087](https://github.com/danielgindi/Charts/pull/3087) ([jjatie](https://github.com/jjatie))
- for \#2745. chart should be weak. [\#3078](https://github.com/danielgindi/Charts/pull/3078) ([liuxuan30](https://github.com/liuxuan30))
- Fix a bug may cause infinite loop. [\#3073](https://github.com/danielgindi/Charts/pull/3073) ([JyHu](https://github.com/JyHu))
- Removed `isKind\(of:\)` [\#3044](https://github.com/danielgindi/Charts/pull/3044) ([jjatie](https://github.com/jjatie))
- Removed redundant ivars in BarLineChartViewBase [\#3043](https://github.com/danielgindi/Charts/pull/3043) ([jjatie](https://github.com/jjatie))
- fileprivate -\> private [\#3042](https://github.com/danielgindi/Charts/pull/3042) ([jjatie](https://github.com/jjatie))
- Viewportjob minor cleanup [\#3041](https://github.com/danielgindi/Charts/pull/3041) ([jjatie](https://github.com/jjatie))
- Removed @objc from internal properties [\#3038](https://github.com/danielgindi/Charts/pull/3038) ([jjatie](https://github.com/jjatie))
- Minor changes to BubbleChartRenderer logic [\#3010](https://github.com/danielgindi/Charts/pull/3010) ([jjatie](https://github.com/jjatie))
- Minor changes to Animator [\#3005](https://github.com/danielgindi/Charts/pull/3005) ([jjatie](https://github.com/jjatie))
- Minor cleanup to Highlighter types [\#3003](https://github.com/danielgindi/Charts/pull/3003) ([jjatie](https://github.com/jjatie))
- Resubmit of \#2730 [\#3002](https://github.com/danielgindi/Charts/pull/3002) ([jjatie](https://github.com/jjatie))
- The backing var is not necessary. [\#3000](https://github.com/danielgindi/Charts/pull/3000) ([jjatie](https://github.com/jjatie))
- Minor refactoring of Formatter logic [\#2998](https://github.com/danielgindi/Charts/pull/2998) ([jjatie](https://github.com/jjatie))
- Removed methods and properties deprecated in 1.0 [\#2996](https://github.com/danielgindi/Charts/pull/2996) ([jjatie](https://github.com/jjatie))
- Replaced `ChartUtils` methods with `CGSize` extensions [\#2995](https://github.com/danielgindi/Charts/pull/2995) ([jjatie](https://github.com/jjatie))
- Replaced relevant `ChartUtils` methods with `Double` extensions [\#2994](https://github.com/danielgindi/Charts/pull/2994) ([jjatie](https://github.com/jjatie))
- Replaced `ChartUtils.Math` in favour of an extension on `FloatingPoint` [\#2993](https://github.com/danielgindi/Charts/pull/2993) ([jjatie](https://github.com/jjatie))
- Minor changes to logic in `ViewPortJob` subclasses. [\#2992](https://github.com/danielgindi/Charts/pull/2992) ([jjatie](https://github.com/jjatie))
- `ChartRenderer`'s must be initialized with a chart [\#2982](https://github.com/danielgindi/Charts/pull/2982) ([jjatie](https://github.com/jjatie))
- Animator non nil [\#2981](https://github.com/danielgindi/Charts/pull/2981) ([jjatie](https://github.com/jjatie))
- View port handler nonnil [\#2980](https://github.com/danielgindi/Charts/pull/2980) ([jjatie](https://github.com/jjatie))
- Add support for iPhone X [\#2967](https://github.com/danielgindi/Charts/pull/2967) ([liuxuan30](https://github.com/liuxuan30))
- added highlightColor parameter for pie charts [\#2961](https://github.com/danielgindi/Charts/pull/2961) ([pascalherrmann](https://github.com/pascalherrmann))
- Add Swift Package Manager support. [\#2950](https://github.com/danielgindi/Charts/pull/2950) ([BrianDoig](https://github.com/BrianDoig))
- Fix turning off drag in X and Y axes separately. [\#2949](https://github.com/danielgindi/Charts/pull/2949) ([maciejtrybilo](https://github.com/maciejtrybilo))
- modify for Character Alert: characters is deprecated [\#2942](https://github.com/danielgindi/Charts/pull/2942) ([suzuhiroruri](https://github.com/suzuhiroruri))
- fix \#2890. Turned out it's multiple bar chart but not grouped [\#2891](https://github.com/danielgindi/Charts/pull/2891) ([liuxuan30](https://github.com/liuxuan30))
- Update LICENSE [\#2887](https://github.com/danielgindi/Charts/pull/2887) ([sDaniel](https://github.com/sDaniel))
- fix \#1830. credit from https://github.com/danielgindi/Charts/pull/2049 [\#2874](https://github.com/danielgindi/Charts/pull/2874) ([liuxuan30](https://github.com/liuxuan30))
- duplicated code for set1 in set2 section [\#2872](https://github.com/danielgindi/Charts/pull/2872) ([liuxuan30](https://github.com/liuxuan30))
- added DataApproximator+N extension [\#2848](https://github.com/danielgindi/Charts/pull/2848) ([666tos](https://github.com/666tos))
- Bumped pod version [\#2806](https://github.com/danielgindi/Charts/pull/2806) ([mohpor](https://github.com/mohpor))
- unwrap optionals [\#2698](https://github.com/danielgindi/Charts/pull/2698) ([russellbstephens](https://github.com/russellbstephens))
- Replaced unnecessary NSObjectProtocol [\#2629](https://github.com/danielgindi/Charts/pull/2629) ([jjatie](https://github.com/jjatie))
- Swift iOS Demos [\#2628](https://github.com/danielgindi/Charts/pull/2628) ([jjatie](https://github.com/jjatie))
- add example playground [\#2364](https://github.com/danielgindi/Charts/pull/2364) ([thierryH91200](https://github.com/thierryH91200))
- Compatibility with swift playgrounds [\#2335](https://github.com/danielgindi/Charts/pull/2335) ([macteo](https://github.com/macteo))

## [v3.0.4](https://github.com/danielgindi/Charts/tree/v3.0.4) (2017-09-21)

[Full Changelog](https://github.com/danielgindi/Charts/compare/3.0.4...v3.0.4)

## [3.0.4](https://github.com/danielgindi/Charts/tree/3.0.4) (2017-09-21)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.0.3...3.0.4)

**Merged pull requests:**

- Changes for Swift 4 [\#2507](https://github.com/danielgindi/Charts/pull/2507) ([liuxuan30](https://github.com/liuxuan30))

## [v3.0.3](https://github.com/danielgindi/Charts/tree/v3.0.3) (2017-09-08)

[Full Changelog](https://github.com/danielgindi/Charts/compare/3.0.3...v3.0.3)

## [3.0.3](https://github.com/danielgindi/Charts/tree/3.0.3) (2017-09-08)

[Full Changelog](https://github.com/danielgindi/Charts/compare/3.0.2...3.0.3)

**Merged pull requests:**

- Update xcode project for xcode 9 [\#2767](https://github.com/danielgindi/Charts/pull/2767) ([petester42](https://github.com/petester42))
- Fixed value setter on PieChartDataEntry [\#2754](https://github.com/danielgindi/Charts/pull/2754) ([martnst](https://github.com/martnst))
- Conform to macOS api changes in swift 3.2 [\#2717](https://github.com/danielgindi/Charts/pull/2717) ([ohbargain](https://github.com/ohbargain))
- Fix CombinedChartView not draw markers [\#2702](https://github.com/danielgindi/Charts/pull/2702) ([xzysun](https://github.com/xzysun))
- Reduce build time with minor reference refactor [\#2679](https://github.com/danielgindi/Charts/pull/2679) ([xinranw](https://github.com/xinranw))
- Fix Typo: Probider -\> Provider [\#2650](https://github.com/danielgindi/Charts/pull/2650) ([russellbstephens](https://github.com/russellbstephens))
- Adding a third party tutorial [\#2604](https://github.com/danielgindi/Charts/pull/2604) ([osianSmith](https://github.com/osianSmith))
- fix \#2099, avoid crash when some chart only allow 1 data set [\#2500](https://github.com/danielgindi/Charts/pull/2500) ([liuxuan30](https://github.com/liuxuan30))
- tutorial link added to readme [\#2484](https://github.com/danielgindi/Charts/pull/2484) ([annalizhaz](https://github.com/annalizhaz))
- Allow turning off drag in X and Y axes separately. [\#2413](https://github.com/danielgindi/Charts/pull/2413) ([maciejtrybilo](https://github.com/maciejtrybilo))
- Run view port jobs afterwards \(Fixes \#2395\) [\#2396](https://github.com/danielgindi/Charts/pull/2396) ([feosuna1](https://github.com/feosuna1))
- Minor improvements in BalloonMarker.swift [\#2393](https://github.com/danielgindi/Charts/pull/2393) ([valeriyvan](https://github.com/valeriyvan))
- remove build for ci tests procedure, use `clean test` directly [\#2388](https://github.com/danielgindi/Charts/pull/2388) ([liuxuan30](https://github.com/liuxuan30))
- Update Travis config for Xcode 8.3 and fix test failures [\#2378](https://github.com/danielgindi/Charts/pull/2378) ([liuxuan30](https://github.com/liuxuan30))
- Fix Simple Bar Chart Demo, switch use of x and y values [\#2365](https://github.com/danielgindi/Charts/pull/2365) ([franqueli](https://github.com/franqueli))
- Bug fixing with one line, updating ChartViewBase.swift [\#2355](https://github.com/danielgindi/Charts/pull/2355) ([Eric0625](https://github.com/Eric0625))
- Fixed, If the last value is the max or min, the range will be wrong [\#2229](https://github.com/danielgindi/Charts/pull/2229) ([aelam](https://github.com/aelam))
- fix \#2222 move default backgroundColor to initialize\(\) [\#2228](https://github.com/danielgindi/Charts/pull/2228) ([liuxuan30](https://github.com/liuxuan30))
- Fix \#1879. Similar cut in half issue in scatter chart like others [\#1891](https://github.com/danielgindi/Charts/pull/1891) ([liuxuan30](https://github.com/liuxuan30))

## [3.0.2](https://github.com/danielgindi/Charts/tree/3.0.2) (2017-04-02)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.0.2...3.0.2)

## [v3.0.2](https://github.com/danielgindi/Charts/tree/v3.0.2) (2017-04-02)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.0.1...v3.0.2)

**Merged pull requests:**

- Minor typo fix in console alert message "it's" -\> "its" [\#2301](https://github.com/danielgindi/Charts/pull/2301) ([simonbromberg](https://github.com/simonbromberg))
- Fix Xcode 8.3 compiler warnings [\#2279](https://github.com/danielgindi/Charts/pull/2279) ([krbarnes](https://github.com/krbarnes))
- Updated to use Realm version 2.4.3 [\#2199](https://github.com/danielgindi/Charts/pull/2199) ([kimdv](https://github.com/kimdv))
- Fixed the inconsistency of AxisMax and AxisMin [\#2177](https://github.com/danielgindi/Charts/pull/2177) ([aelam](https://github.com/aelam))
- Fixes index out of range crash. [\#2167](https://github.com/danielgindi/Charts/pull/2167) ([kzaher](https://github.com/kzaher))
- 'backgroundColor' is inaccessible due to 'internal' protection level … [\#2156](https://github.com/danielgindi/Charts/pull/2156) ([thierryH91200](https://github.com/thierryH91200))
- Adds NSPhotoLibraryUsageDescription to plist of ChartsDemo [\#2101](https://github.com/danielgindi/Charts/pull/2101) ([valeriyvan](https://github.com/valeriyvan))
- Fix demo and test targets not running/testing [\#2084](https://github.com/danielgindi/Charts/pull/2084) ([petester42](https://github.com/petester42))
- fix a typo, as orientation is horizontal by default [\#2078](https://github.com/danielgindi/Charts/pull/2078) ([liuxuan30](https://github.com/liuxuan30))
- Update Podspec RealmSwift Dependency to 2.1.1 to be in line with Cartfile [\#2064](https://github.com/danielgindi/Charts/pull/2064) ([anttyc](https://github.com/anttyc))
- Fix NSCopying implementation in CandleChartDataEntry [\#2056](https://github.com/danielgindi/Charts/pull/2056) ([leo150](https://github.com/leo150))
- Add support for extensions [\#2048](https://github.com/danielgindi/Charts/pull/2048) ([raptorxcz](https://github.com/raptorxcz))
- Update "Usage" section of README [\#1984](https://github.com/danielgindi/Charts/pull/1984) ([elaewin](https://github.com/elaewin))
- All Charts Icons Support Swift3 \[Dub \#629, \#624, \#1261\] [\#1793](https://github.com/danielgindi/Charts/pull/1793) ([abjurato](https://github.com/abjurato))

## [v3.0.1](https://github.com/danielgindi/Charts/tree/v3.0.1) (2016-11-20)

[Full Changelog](https://github.com/danielgindi/Charts/compare/3.0.1...v3.0.1)

## [3.0.1](https://github.com/danielgindi/Charts/tree/3.0.1) (2016-11-20)

[Full Changelog](https://github.com/danielgindi/Charts/compare/2.3.1...3.0.1)

**Merged pull requests:**

- Updated Width Constraints - Fixes \#1770 [\#1771](https://github.com/danielgindi/Charts/pull/1771) ([SumoSimo](https://github.com/SumoSimo))
- Added a check against NaN [\#1733](https://github.com/danielgindi/Charts/pull/1733) ([Selficide](https://github.com/Selficide))
- update cocoapods [\#1684](https://github.com/danielgindi/Charts/pull/1684) ([petester42](https://github.com/petester42))

## [2.3.1](https://github.com/danielgindi/Charts/tree/2.3.1) (2016-11-04)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.3.1...2.3.1)

## [v2.3.1](https://github.com/danielgindi/Charts/tree/v2.3.1) (2016-11-04)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v3.0.0...v2.3.1)

**Merged pull requests:**

- Fix png image using JPEG type when being saved on macOS [\#1783](https://github.com/danielgindi/Charts/pull/1783) ([petester42](https://github.com/petester42))

## [v3.0.0](https://github.com/danielgindi/Charts/tree/v3.0.0) (2016-10-19)

[Full Changelog](https://github.com/danielgindi/Charts/compare/3.0.0...v3.0.0)

## [3.0.0](https://github.com/danielgindi/Charts/tree/3.0.0) (2016-10-19)

[Full Changelog](https://github.com/danielgindi/Charts/compare/2.3.0...3.0.0)

**Merged pull requests:**

- Enter the matrix [\#1650](https://github.com/danielgindi/Charts/pull/1650) ([petester42](https://github.com/petester42))
- fix bar chart in demo that date starts at 0 [\#1648](https://github.com/danielgindi/Charts/pull/1648) ([liuxuan30](https://github.com/liuxuan30))
- fix \#1603 and API comment [\#1621](https://github.com/danielgindi/Charts/pull/1621) ([liuxuan30](https://github.com/liuxuan30))
- Bugfix for fix \#1488, \#1564 [\#1565](https://github.com/danielgindi/Charts/pull/1565) ([liuxuan30](https://github.com/liuxuan30))
- Single test target to make coverage easier [\#1563](https://github.com/danielgindi/Charts/pull/1563) ([petester42](https://github.com/petester42))
- Fix codecov [\#1560](https://github.com/danielgindi/Charts/pull/1560) ([petester42](https://github.com/petester42))
- Adds Codecov [\#1559](https://github.com/danielgindi/Charts/pull/1559) ([petester42](https://github.com/petester42))
- Fix decimals crash in ChartsUtil [\#1558](https://github.com/danielgindi/Charts/pull/1558) ([petester42](https://github.com/petester42))
- Fixes messaging issues with charts needing carthage [\#1525](https://github.com/danielgindi/Charts/pull/1525) ([petester42](https://github.com/petester42))
- Attempt to make CI more stable [\#1510](https://github.com/danielgindi/Charts/pull/1510) ([petester42](https://github.com/petester42))
- Fix Cocoapods setup being broken [\#1509](https://github.com/danielgindi/Charts/pull/1509) ([petester42](https://github.com/petester42))
- bump Charts version to 3.0.0 [\#1505](https://github.com/danielgindi/Charts/pull/1505) ([liuxuan30](https://github.com/liuxuan30))
- porting \#1452 into master [\#1486](https://github.com/danielgindi/Charts/pull/1486) ([liuxuan30](https://github.com/liuxuan30))
- Don't override project settings in targets [\#1484](https://github.com/danielgindi/Charts/pull/1484) ([petester42](https://github.com/petester42))
- change Charts baseSDK to iOS 10 [\#1467](https://github.com/danielgindi/Charts/pull/1467) ([liuxuan30](https://github.com/liuxuan30))
- migrate more ChartsDemo project setting to swift 3.0 [\#1466](https://github.com/danielgindi/Charts/pull/1466) ([liuxuan30](https://github.com/liuxuan30))
- Update project structure for simplicity and fixing carthage [\#1422](https://github.com/danielgindi/Charts/pull/1422) ([petester42](https://github.com/petester42))
- When only one of scaleXEnabled or scaleYEnabled is effective [\#1319](https://github.com/danielgindi/Charts/pull/1319) ([essoecc](https://github.com/essoecc))
- V3 [\#1318](https://github.com/danielgindi/Charts/pull/1318) ([vishaldeshai](https://github.com/vishaldeshai))
- fix Realm pod spec typo [\#1271](https://github.com/danielgindi/Charts/pull/1271) ([liuxuan30](https://github.com/liuxuan30))
- improve comment to warn users how to use setVisibleRange APIs [\#1245](https://github.com/danielgindi/Charts/pull/1245) ([liuxuan30](https://github.com/liuxuan30))
- for \#1208, seems drawBarShadowEnabled should be false by default [\#1226](https://github.com/danielgindi/Charts/pull/1226) ([liuxuan30](https://github.com/liuxuan30))

## [2.3.0](https://github.com/danielgindi/Charts/tree/2.3.0) (2016-09-21)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.3.0...2.3.0)

## [v2.3.0](https://github.com/danielgindi/Charts/tree/v2.3.0) (2016-09-21)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.2.5...v2.3.0)

**Merged pull requests:**

- Few more changes needed to build with Swift 2.3 [\#1281](https://github.com/danielgindi/Charts/pull/1281) ([EpicDraws](https://github.com/EpicDraws))
- Swift 2.3 [\#1163](https://github.com/danielgindi/Charts/pull/1163) ([liuxuan30](https://github.com/liuxuan30))
- Ignoring .DS\_Store files [\#1130](https://github.com/danielgindi/Charts/pull/1130) ([einsteinx2](https://github.com/einsteinx2))

## [v2.2.5](https://github.com/danielgindi/Charts/tree/v2.2.5) (2016-05-30)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.2.4...v2.2.5)

**Merged pull requests:**

- Revert "Simple changes to allow OS X 10.10 support" [\#1088](https://github.com/danielgindi/Charts/pull/1088) ([danielgindi](https://github.com/danielgindi))
- Simple changes to allow OS X 10.10 support [\#1087](https://github.com/danielgindi/Charts/pull/1087) ([einsteinx2](https://github.com/einsteinx2))
- Fix \#1014: fix combined chart crash while toggle bar borders [\#1015](https://github.com/danielgindi/Charts/pull/1015) ([liuxuan30](https://github.com/liuxuan30))
- Highlight enhancements \(Closes \#654, closes \#702\) [\#1012](https://github.com/danielgindi/Charts/pull/1012) ([danielgindi](https://github.com/danielgindi))
- Fix typo [\#949](https://github.com/danielgindi/Charts/pull/949) ([emiranda04](https://github.com/emiranda04))
- fix \#940. another loop bounds crash [\#941](https://github.com/danielgindi/Charts/pull/941) ([liuxuan30](https://github.com/liuxuan30))
- Fix a crash when using markers with a PieChart [\#937](https://github.com/danielgindi/Charts/pull/937) ([rofreg](https://github.com/rofreg))
- Horizontal cubic line [\#935](https://github.com/danielgindi/Charts/pull/935) ([danielgindi](https://github.com/danielgindi))
- Property circleHoleRadius added to ILineChartDataSet protocol.  [\#934](https://github.com/danielgindi/Charts/pull/934) ([olbartek](https://github.com/olbartek))
- replace old github link to latest https://github.com/danielgindi/Charts [\#932](https://github.com/danielgindi/Charts/pull/932) ([liuxuan30](https://github.com/liuxuan30))
- Some minor nits [\#913](https://github.com/danielgindi/Charts/pull/913) ([ruurd](https://github.com/ruurd))
- add a switch whether to draw limit line's labels. default is true [\#887](https://github.com/danielgindi/Charts/pull/887) ([liuxuan30](https://github.com/liuxuan30))
- Add new pie chart renderer with polyline indicate [\#869](https://github.com/danielgindi/Charts/pull/869) ([wjacker](https://github.com/wjacker))
- Supporting borders on bars, Fixes issue \#822 [\#844](https://github.com/danielgindi/Charts/pull/844) ([AndreasIgelCC](https://github.com/AndreasIgelCC))

## [v2.2.4](https://github.com/danielgindi/Charts/tree/v2.2.4) (2016-03-31)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.2.3...v2.2.4)

**Merged pull requests:**

- remove duplicated statement [\#894](https://github.com/danielgindi/Charts/pull/894) ([liuxuan30](https://github.com/liuxuan30))
- Add a Gitter chat badge to README.md [\#861](https://github.com/danielgindi/Charts/pull/861) ([gitter-badger](https://github.com/gitter-badger))
- Type bug in PieChartData [\#847](https://github.com/danielgindi/Charts/pull/847) ([leoMehlig](https://github.com/leoMehlig))
- Update Readme [\#828](https://github.com/danielgindi/Charts/pull/828) ([PhilJay](https://github.com/PhilJay))
- Keep position on rotation [\#824](https://github.com/danielgindi/Charts/pull/824) ([leoMehlig](https://github.com/leoMehlig))
- Set code signing identity for iOS targets [\#811](https://github.com/danielgindi/Charts/pull/811) ([krbarnes](https://github.com/krbarnes))
- Add trailing newline for preprocessor statement [\#795](https://github.com/danielgindi/Charts/pull/795) ([boourns](https://github.com/boourns))
- Feature \#539 Stepped line charts [\#778](https://github.com/danielgindi/Charts/pull/778) ([ezamagni](https://github.com/ezamagni))
- add support for lineCap setting for line chart [\#658](https://github.com/danielgindi/Charts/pull/658) ([liuxuan30](https://github.com/liuxuan30))

## [v2.2.3](https://github.com/danielgindi/Charts/tree/v2.2.3) (2016-02-29)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.2.2...v2.2.3)

**Merged pull requests:**

- Add "Toggle Data" option to demo charts. \(\#771 Support\) [\#781](https://github.com/danielgindi/Charts/pull/781) ([ospr](https://github.com/ospr))
- Add missing UIKit imports for iOS 7 [\#780](https://github.com/danielgindi/Charts/pull/780) ([asmarques](https://github.com/asmarques))
- Make ChartViewBase's \_data optional. \(Fixes \#771\) [\#772](https://github.com/danielgindi/Charts/pull/772) ([ospr](https://github.com/ospr))
- Add Carthage compatibility badge [\#769](https://github.com/danielgindi/Charts/pull/769) ([Bogidon](https://github.com/Bogidon))
- update cocoapods url [\#755](https://github.com/danielgindi/Charts/pull/755) ([stevenedds](https://github.com/stevenedds))
- add ci status [\#752](https://github.com/danielgindi/Charts/pull/752) ([petester42](https://github.com/petester42))
- Correct the spelling of CocoaPods in README [\#751](https://github.com/danielgindi/Charts/pull/751) ([ReadmeCritic](https://github.com/ReadmeCritic))
- LineChartRenderer context bug [\#746](https://github.com/danielgindi/Charts/pull/746) ([leoMehlig](https://github.com/leoMehlig))
- Fix for cubic line chart fill when charts that don't start at x-index 0 \#711 [\#712](https://github.com/danielgindi/Charts/pull/712) ([gunterhager](https://github.com/gunterhager))
- add an option to set line cap of axis grid line [\#660](https://github.com/danielgindi/Charts/pull/660) ([mconintet](https://github.com/mconintet))

## [v2.2.2](https://github.com/danielgindi/Charts/tree/v2.2.2) (2016-02-09)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.2.1...v2.2.2)

## [v2.2.1](https://github.com/danielgindi/Charts/tree/v2.2.1) (2016-02-01)

[Full Changelog](https://github.com/danielgindi/Charts/compare/2.2.1...v2.2.1)

## [2.2.1](https://github.com/danielgindi/Charts/tree/2.2.1) (2016-02-01)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.2.0...2.2.1)

**Merged pull requests:**

- Update podspec for realm and 2.2.0 [\#725](https://github.com/danielgindi/Charts/pull/725) ([petester42](https://github.com/petester42))

## [v2.2.0](https://github.com/danielgindi/Charts/tree/v2.2.0) (2016-01-26)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.1.6...v2.2.0)

**Merged pull requests:**

- Activate require app extension safe API to be able to use library inside an app extension [\#708](https://github.com/danielgindi/Charts/pull/708) ([ghost](https://github.com/ghost))
- fix code indent problem in ChartYAxisRendererRadarChart, ChartYAxisRenderer, BarChartDataSet, RadarChartView [\#675](https://github.com/danielgindi/Charts/pull/675) ([liuxuan30](https://github.com/liuxuan30))
- Fix minor typo in BarLineChartViewBase [\#651](https://github.com/danielgindi/Charts/pull/651) ([patrickreynolds](https://github.com/patrickreynolds))
- Adapted ChartLegendRenderer class to upcoming Swift 3 changes and improved code readability [\#643](https://github.com/danielgindi/Charts/pull/643) ([zntfdr](https://github.com/zntfdr))
- Remove verbose semicolons [\#639](https://github.com/danielgindi/Charts/pull/639) ([AntiMoron](https://github.com/AntiMoron))
- Adds CI [\#636](https://github.com/danielgindi/Charts/pull/636) ([petester42](https://github.com/petester42))
- Add missing images for bar chart tests [\#635](https://github.com/danielgindi/Charts/pull/635) ([petester42](https://github.com/petester42))
- Use nil coalescing in ChartDataSet's entryCount \(Fixes \#631\) [\#632](https://github.com/danielgindi/Charts/pull/632) ([aarondaub](https://github.com/aarondaub))
- Remove useless parentheses causing swift build error [\#614](https://github.com/danielgindi/Charts/pull/614) ([chanil1218](https://github.com/chanil1218))
- Add change log file. [\#605](https://github.com/danielgindi/Charts/pull/605) ([skywinder](https://github.com/skywinder))
- add initialize dataSets in setter [\#600](https://github.com/danielgindi/Charts/pull/600) ([liuxuan30](https://github.com/liuxuan30))
- Bar chart tests [\#580](https://github.com/danielgindi/Charts/pull/580) ([alvesjtiago](https://github.com/alvesjtiago))
- Make getBarBounds callable from Objective-C code \(Fixes \#570\) [\#571](https://github.com/danielgindi/Charts/pull/571) ([ghost](https://github.com/ghost))
- round the float value before we cast to Int [\#558](https://github.com/danielgindi/Charts/pull/558) ([liuxuan30](https://github.com/liuxuan30))

## [v2.1.6](https://github.com/danielgindi/Charts/tree/v2.1.6) (2015-11-02)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.1.5...v2.1.6)

**Merged pull requests:**

- Implemented support for rotated labels on the x-axis [\#513](https://github.com/danielgindi/Charts/pull/513) ([danielgindi](https://github.com/danielgindi))
- update targets to build framework with same name [\#501](https://github.com/danielgindi/Charts/pull/501) ([petester42](https://github.com/petester42))
- Adds test support without cocoapods [\#500](https://github.com/danielgindi/Charts/pull/500) ([petester42](https://github.com/petester42))
- Fixed drag offset panning bug [\#498](https://github.com/danielgindi/Charts/pull/498) ([leoMehlig](https://github.com/leoMehlig))
- Revert "BUGFIX:fix xAxis labels of bar chart" [\#497](https://github.com/danielgindi/Charts/pull/497) ([danielgindi](https://github.com/danielgindi))
- if only line data exists and no other data, turn \_deltaX to 1.0 [\#493](https://github.com/danielgindi/Charts/pull/493) ([liuxuan30](https://github.com/liuxuan30))
- BUGFIX:fix xAxis labels of bar chart [\#489](https://github.com/danielgindi/Charts/pull/489) ([AntiMoron](https://github.com/AntiMoron))
- Fix issue related to PhilJay/MPAndroidChart\#1121 [\#488](https://github.com/danielgindi/Charts/pull/488) ([PhilJay](https://github.com/PhilJay))
- Approved, pending styling: Fix Scroll issue when the graph is in a UITableView [\#464](https://github.com/danielgindi/Charts/pull/464) ([coupgar](https://github.com/coupgar))
- Add ability to turn off antialias for grid lines [\#462](https://github.com/danielgindi/Charts/pull/462) ([vvit](https://github.com/vvit))

## [v2.1.5](https://github.com/danielgindi/Charts/tree/v2.1.5) (2015-10-15)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.1.4a...v2.1.5)

**Merged pull requests:**

- Changed \_chart access modifier from private to internal [\#478](https://github.com/danielgindi/Charts/pull/478) ([AlBirdie](https://github.com/AlBirdie))
- fixed noDataText and NoDataTextDescription texts ovelapping issue [\#457](https://github.com/danielgindi/Charts/pull/457) ([zntfdr](https://github.com/zntfdr))
- Only alow scaling further if the user can still zoom \(Fixes \#437\) [\#438](https://github.com/danielgindi/Charts/pull/438) ([iangmaia](https://github.com/iangmaia))
- Make the ChartXAxisRenderer more flexible: now possible to overwrite drawing the line or label of the ChartLimitLine [\#432](https://github.com/danielgindi/Charts/pull/432) ([pajai](https://github.com/pajai))

## [v2.1.4a](https://github.com/danielgindi/Charts/tree/v2.1.4a) (2015-10-02)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.1.4...v2.1.4a)

**Merged pull requests:**

- Start of pan gesture should not be cancelled by no drag [\#420](https://github.com/danielgindi/Charts/pull/420) ([niraj-rayalla](https://github.com/niraj-rayalla))
- Allow the minimum offset to be customized [\#395](https://github.com/danielgindi/Charts/pull/395) ([icecrystal23](https://github.com/icecrystal23))
- Add support for a legend above the chart [\#393](https://github.com/danielgindi/Charts/pull/393) ([icecrystal23](https://github.com/icecrystal23))
- Add target for tvOS and get it to compile [\#392](https://github.com/danielgindi/Charts/pull/392) ([icecrystal23](https://github.com/icecrystal23))
- be explicit on how to install 'Charts' when using CocoaPods since [\#376](https://github.com/danielgindi/Charts/pull/376) ([codeHatcher](https://github.com/codeHatcher))

## [v2.1.4](https://github.com/danielgindi/Charts/tree/v2.1.4) (2015-09-21)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.1.3...v2.1.4)

**Merged pull requests:**

- Allow setting maximum y-scale factor [\#388](https://github.com/danielgindi/Charts/pull/388) ([noais](https://github.com/noais))
- Swift 2.0 [\#386](https://github.com/danielgindi/Charts/pull/386) ([danielgindi](https://github.com/danielgindi))
- Fix default value of forceLabelsEnabled [\#360](https://github.com/danielgindi/Charts/pull/360) ([yas375](https://github.com/yas375))
- Update BarLineChartViewBase.swift [\#359](https://github.com/danielgindi/Charts/pull/359) ([Ewg777](https://github.com/Ewg777))
- combined chart - seems we should use same chartXMin and chartXMax even there is no bubble data [\#324](https://github.com/danielgindi/Charts/pull/324) ([liuxuan30](https://github.com/liuxuan30))
- fix pie chart clipping [\#313](https://github.com/danielgindi/Charts/pull/313) ([petester42](https://github.com/petester42))
- bump podspec to 2.1.3 [\#290](https://github.com/danielgindi/Charts/pull/290) ([petester42](https://github.com/petester42))
- Minor refactor for BarLineChartViewBase [\#268](https://github.com/danielgindi/Charts/pull/268) ([liuxuan30](https://github.com/liuxuan30))
- Enhanced label positioning at limit lines \(enum ChartLimitLabelPosition\) [\#243](https://github.com/danielgindi/Charts/pull/243) ([SvenMuc](https://github.com/SvenMuc))
- fix radar chart negative value rendering bug if startAtZeroEnabled is false for issue \#166 [\#207](https://github.com/danielgindi/Charts/pull/207) ([liuxuan30](https://github.com/liuxuan30))
- Performance Enhancements \#29 - candle chart [\#192](https://github.com/danielgindi/Charts/pull/192) ([dorsoft](https://github.com/dorsoft))

## [v2.1.3](https://github.com/danielgindi/Charts/tree/v2.1.3) (2015-08-05)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.1.2...v2.1.3)

**Merged pull requests:**

- Add a Code Hunt vote badge to README.md [\#262](https://github.com/danielgindi/Charts/pull/262) ([CodeHuntIO](https://github.com/CodeHuntIO))
- Updated podspec [\#254](https://github.com/danielgindi/Charts/pull/254) ([petester42](https://github.com/petester42))
- try to fix bar chart + Horizontal Bar chart wrong render + highlight position bug for issue \#214 and \#242. [\#248](https://github.com/danielgindi/Charts/pull/248) ([liuxuan30](https://github.com/liuxuan30))

## [v2.1.2](https://github.com/danielgindi/Charts/tree/v2.1.2) (2015-07-26)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.1.1...v2.1.2)

## [v2.1.1](https://github.com/danielgindi/Charts/tree/v2.1.1) (2015-07-26)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.1.0...v2.1.1)

**Merged pull requests:**

- Candle chart - make the shadow same color as an candle color \#122 [\#191](https://github.com/danielgindi/Charts/pull/191) ([dorsoft](https://github.com/dorsoft))
- ChartData.removeEntryByXIndex removes the wrong entry \#182 [\#185](https://github.com/danielgindi/Charts/pull/185) ([dorsoft](https://github.com/dorsoft))
- The line charts have started to properly display balloon markers [\#179](https://github.com/danielgindi/Charts/pull/179) ([Maxim-38RUS-Zabelin](https://github.com/Maxim-38RUS-Zabelin))
- Fix a silly bug. should check if first is -0.0 [\#165](https://github.com/danielgindi/Charts/pull/165) ([liuxuan30](https://github.com/liuxuan30))
- add NaN check to allow non-digits handling for radar chart [\#152](https://github.com/danielgindi/Charts/pull/152) ([liuxuan30](https://github.com/liuxuan30))
- optional protocol method should not be force unwrapped [\#147](https://github.com/danielgindi/Charts/pull/147) ([liuxuan30](https://github.com/liuxuan30))
- add missing module CoreGraphics for BubbleChartView [\#146](https://github.com/danielgindi/Charts/pull/146) ([liuxuan30](https://github.com/liuxuan30))
- Adding a minimum parameter to setVisibleXRange [\#119](https://github.com/danielgindi/Charts/pull/119) ([dorsoft](https://github.com/dorsoft))
- Added support for setting a custom width that is wider than the longe… [\#107](https://github.com/danielgindi/Charts/pull/107) ([AlBirdie](https://github.com/AlBirdie))
- Offset adjustment when drawLabels on the x axis is disabled. [\#106](https://github.com/danielgindi/Charts/pull/106) ([AlBirdie](https://github.com/AlBirdie))
- AutoScaling yAxis during panning / zooming [\#95](https://github.com/danielgindi/Charts/pull/95) ([AlBirdie](https://github.com/AlBirdie))
- Allow access to setLabelsToSkip from Objective-C. [\#93](https://github.com/danielgindi/Charts/pull/93) ([mkubenka](https://github.com/mkubenka))
- Changing iOS deployment target to 8.0 from 8.1 [\#74](https://github.com/danielgindi/Charts/pull/74) ([michaelmcguire](https://github.com/michaelmcguire))

## [v2.1.0](https://github.com/danielgindi/Charts/tree/v2.1.0) (2015-05-05)

[Full Changelog](https://github.com/danielgindi/Charts/compare/v2.0.9...v2.1.0)

**Merged pull requests:**

- Fix x-axis limit line render issue. [\#66](https://github.com/danielgindi/Charts/pull/66) ([mkubenka](https://github.com/mkubenka))
- Added possibility to set the axisLabelModulus manually. [\#56](https://github.com/danielgindi/Charts/pull/56) ([webventil](https://github.com/webventil))
- Add missing UIKit imports for iOS 7 support [\#45](https://github.com/danielgindi/Charts/pull/45) ([msanders](https://github.com/msanders))
- Add 'init' to PieChartData to be used from Swift [\#37](https://github.com/danielgindi/Charts/pull/37) ([jmnavarro](https://github.com/jmnavarro))
- Added Bubble Chart Type [\#25](https://github.com/danielgindi/Charts/pull/25) ([petester42](https://github.com/petester42))
- Shared Charts.framework scheme [\#22](https://github.com/danielgindi/Charts/pull/22) ([zenkimoto](https://github.com/zenkimoto))
- Add missing UIKit [\#20](https://github.com/danielgindi/Charts/pull/20) ([mkalmes](https://github.com/mkalmes))

## [v2.0.9](https://github.com/danielgindi/Charts/tree/v2.0.9) (2015-04-08)

[Full Changelog](https://github.com/danielgindi/Charts/compare/0.0.1...v2.0.9)

**Merged pull requests:**

- Added a podspec [\#13](https://github.com/danielgindi/Charts/pull/13) ([petester42](https://github.com/petester42))

## [0.0.1](https://github.com/danielgindi/Charts/tree/0.0.1) (2015-04-07)

[Full Changelog](https://github.com/danielgindi/Charts/compare/72652ef3ef988664c9b543bb9f38617e46cc68d7...0.0.1)

**Merged pull requests:**

- Fix README typo [\#5](https://github.com/danielgindi/Charts/pull/5) ([nwest](https://github.com/nwest))
- Add a Bitdeli Badge to README [\#1](https://github.com/danielgindi/Charts/pull/1) ([bitdeli-chef](https://github.com/bitdeli-chef))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
