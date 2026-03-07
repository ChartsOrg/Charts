//
//  AudioGraphSupportChart.swift
//  Charts
//
//  Created by 류성두 on 2022/03/01.
//

import Foundation
import Accessibility

/// Chart that Supports AudioGraph
///
/// To make your graph to support [Audio Graph](https://developer.apple.com/documentation/accessibility/audio_graphs),
/// make your chart to conform to this Protocol. All subclasses of ``BarLineChartViewBase`` already conforms to this protocol
/// If you want cusstom Audio Graph behavior, implement your own ``generateAccessibilityChartDescriptor()-86qt7`` method.
public protocol AudioGraphSupportChart {
    /// Optional String corresponding to the [summary of AXChartDescriptor](https://developer.apple.com/documentation/accessibility/axchartdescriptor/3746749-summary)
    var audioGraphSummary: String { get set }
    /// Optional String describing unit of xAxis
    var audioGraphXAxisTitle: String { get set }
    /// Optional String describing unit of yAxis
    var audioGraphYAxisTitle: String { get set }
    /// Whether the audio graph should play sounds continously
    /// For most charts, default is `false`.
    /// For ``LineChartView``, default is `true`
    var isAudioGraphContinuous: Bool { get set }
    /// Dependent axis of the entry that has VoiceOver focus
    var yAxisForSelectedEntry: YAxis? { get set }

    /// Generate [AXChartDescriptor](https://developer.apple.com/documentation/accessibility/axchartdescriptor) instance
    ///
    /// If you want cusstom Audio Graph behavior, implement your own version of this  method
    @available(macOS 12, iOS 15, watchOS 6, tvOS 15, *)
    func generateAccessibilityChartDescriptor() -> AXChartDescriptor?
    /// updates accessibilityChartDescriptor so that it mirrors the chart correctly
    ///
    /// Call this method whenever any data or metadata of the chart has changed
    func updateAccessibilityChartDesciptor()
    /// Automatically updates ``yAxisForSelectedEntry`` to the dependent axis of the item that has VoiceOver focus
    func automaticallyUpdateYAxisForSelectedEntry()
}

@available(macOS 12, iOS 15, watchOS 6, tvOS 15, *)
extension BarLineChartViewBase: AXChart, AudioGraphSupportChart {}

public extension AudioGraphSupportChart where Self: BarLineChartViewBase {
    func updateAccessibilityChartDesciptor() {
        // Main purpose of this method is to wrapping version check.
        // So that you don't have to add `#if available` everywhere you call ``generateAccessibilityChartDescriptor``
        if #available(macOS 12, iOS 15, watchOS 6, tvOS 15, *) {
            // accessibilityChartDescriptor is only accessible via VoiceOver Rotor
            // So we don't have to generate accessibilityChartDescriptor when VoiceOver is not running
            guard UIAccessibility.isVoiceOverRunning else { return }
            self.accessibilityChartDescriptor = generateAccessibilityChartDescriptor()
        }
    }

    func automaticallyUpdateYAxisForSelectedEntry() {
        NotificationCenter.default.addObserver(forName: UIAccessibility.elementFocusedNotification, object: nil, queue: .main, using: { [weak self] notification in
            let focusedElement = notification.userInfo?["UIAccessibilityFocusedElementKey"] as? NSUIAccessibilityElement
            guard let focusedFrame = focusedElement?.accessibilityFrame else { return }
            guard let sself = self else { return }
            let highlight = sself.getHighlightByTouchPoint(CGPoint(x: focusedFrame.midX, y: focusedFrame.midY))
            sself.yAxisForSelectedEntry = highlight?.axis == .left ? sself.leftAxis : sself.rightAxis
        })
    }
}

@available(macOS 12, iOS 15, watchOS 6, tvOS 15, *)
public extension AudioGraphSupportChart where Self: BarLineChartViewBase {
    func generateAccessibilityChartDescriptor() -> AXChartDescriptor? {
        guard let yAxisDescriptor = yAxisDescriptor else { return nil }
        return AXChartDescriptor(title: chartDescription.text,
                          summary: audioGraphSummary,
                          xAxis: xAxisDescriptor,
                          yAxis: yAxisDescriptor,
                          series: series
        )
    }

    private var xAxisDescriptor: AXDataAxisDescriptor {
        AXNumericDataAxisDescriptor(title: audioGraphXAxisTitle,
                                    range: xAxis.axisMinimum...xAxis.axisMaximum,
                                    gridlinePositions: []) { [xAxis] item in
            return xAxis.valueFormatter?.stringForValue(item, axis: xAxis) ?? "\(item)"
        }
    }

    private var yAxisDescriptor: AXNumericDataAxisDescriptor? {
        guard let yAxis = yAxisForSelectedEntry else { return nil }
        return AXNumericDataAxisDescriptor(title: audioGraphYAxisTitle,
                                           range: yAxis.axisMinimum...yAxis.axisMaximum,
                                           gridlinePositions: []) { [weak self] item in
                guard let yAxis = self?.yAxisForSelectedEntry else { return "\(item)"}
                return yAxis.valueFormatter?.stringForValue(item, axis: yAxis) ?? "\(item)"
            }
    }

    private var series: [AXDataSeriesDescriptor] {
        guard let data = data else { return [] }
        let dataSets = data.compactMap { $0 as? ChartDataSet }
        let isContinous = self.isAudioGraphContinuous
        return dataSets.map { entries in
            let dataPoints = entries.map { AXDataPoint(x: $0.x, y: $0.y, additionalValues: [], label: nil) }
            return AXDataSeriesDescriptor(name: entries.label ?? "", isContinuous: isContinous, dataPoints: dataPoints)
        }
    }
}
