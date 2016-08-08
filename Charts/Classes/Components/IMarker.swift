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

@objc(IChartMarker)
public protocol IMarker: NSObjectProtocol
{
    /// Use this to return the desired offset you wish the IMarker to have on the x-axis.
    var offset: CGPoint { get }
    
    /// The marker's size
    var size: CGSize { get }
    
    /// Returns the offset for drawing at the specific `point`
    ///
    /// - parameter point: This is the point at which the marker wants to be drawn. You can adjust the offset conditionally based on this argument.
    /// - By default returns the self.offset property. You can return any other value to override that.
    func offsetForDrawingAtPos(point: CGPoint) -> CGPoint
    
    /// Draws the ChartMarker on the given position on the given context
    func draw(context context: CGContext, point: CGPoint)
    
    /// This method enables a custom ChartMarker to update it's content everytime the MarkerView is redrawn according to the data entry it points to.
    ///
    /// - parameter highlight: the highlight object contains information about the highlighted value such as it's dataset-index, the selected range or stack-index (only stacked bar entries).
    func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
}