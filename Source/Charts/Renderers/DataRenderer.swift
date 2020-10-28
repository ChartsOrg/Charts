//
//  DataRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

@objc(ChartDataRenderer)
public protocol DataRenderer: Renderer
{
     /// An array of accessibility elements that are presented to the ChartViewBase accessibility methods.
    ///
    /// Note that the order of elements in this array determines the order in which they are presented and navigated by
    /// Accessibility clients such as VoiceOver.
    ///
    /// Renderers should ensure that the order of elements makes sense to a client presenting an audio-only interface to a user.
    /// Subclasses should populate this array in drawData() or drawDataSet() to make the chart accessible.
    var accessibleChartElements: [NSUIAccessibilityElement] { get }

    var animator: Animator { get }

    func drawData(context: CGContext)

    func drawValues(context: CGContext)

    func drawExtras(context: CGContext)

    /// Draws all highlight indicators for the values that are currently highlighted.
    ///
    /// - Parameters:
    ///   - indices: the highlighted values
    func drawHighlighted(context: CGContext, indices: [Highlight])

    /// An opportunity for initializing internal buffers used for rendering with a new size.
    /// Since this might do memory allocations, it should only be called if necessary.
    func initBuffers()

    func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool

    /// Creates an ```NSUIAccessibilityElement``` that acts as the first and primary header describing a chart view.
    ///
    /// - Parameters:
    ///   - chart: The chartView object being described
    ///   - data: A non optional data source about the chart
    ///   - defaultDescription: A simple string describing the type/design of Chart.
    /// - Returns: A header ```NSUIAccessibilityElement``` that can be added to accessibleChartElements.
    func createAccessibleHeader(usingChart chart: ChartViewBase,
                                        andData data: ChartData,
                                        withDefaultDescription defaultDescription: String) -> NSUIAccessibilityElement
}

internal struct AccessibleHeader {
    static func create(usingChart chart: ChartViewBase,
                                andData data: ChartData,
                                withDefaultDescription defaultDescription: String = "Chart") -> NSUIAccessibilityElement
    {
        let chartDescriptionText = chart.chartDescription.text ?? defaultDescription
        let dataSetDescriptions = data.map { $0.label ?? "" }
        let dataSetDescriptionText = dataSetDescriptions.joined(separator: ", ")

        let element = NSUIAccessibilityElement(accessibilityContainer: chart)
        element.accessibilityLabel = chartDescriptionText + ". \(data.count) dataset\(data.count == 1 ? "" : "s"). \(dataSetDescriptionText)"
        element.accessibilityFrame = chart.bounds
        element.isHeader = true
        
        return element
    }
}
