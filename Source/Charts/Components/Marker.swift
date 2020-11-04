//
//  ChartMarker.swift
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

@objc(ChartMarker)
public protocol Marker: class
{
    /// - Returns: The desired (general) offset you wish the IMarker to have on the x-axis.
    /// By returning x: -(width / 2) you will center the IMarker horizontally.
    /// By returning y: -(height / 2) you will center the IMarker vertically.
    var offset: CGPoint { get }
    
    /// - Parameters:
    ///   - point: This is the point at which the marker wants to be drawn. You can adjust the offset conditionally based on this argument.
    /// - Returns: The offset for drawing at the specific `point`.
    ///            This allows conditional adjusting of the Marker position.
    ///            If you have no adjustments to make, return self.offset().
    func offsetForDrawing(atPoint: CGPoint) -> CGPoint
    
    /// This method enables a custom Marker to update it's content every time the Marker is redrawn according to the data entry it points to.
    ///
    /// - Parameters:
    ///   - entry: The Entry the IMarker belongs to. This can also be any subclass of Entry, like BarEntry or CandleEntry, simply cast it at runtime.
    ///   - highlight: The highlight object contains information about the highlighted value such as it's dataset-index, the selected range or stack-index (only stacked bar entries).
    func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    
    /// Draws the Marker on the given position on the given context
    func draw(context: CGContext, point: CGPoint)
}
