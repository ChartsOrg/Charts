//
//  ChartMarkerProtocol.swift
//  Charts
//
//  Created by Dean Yeazel on 8/2/16.
//  Copyright © 2016 dcg. All rights reserved.
//

import Foundation

/// An interface for providing custom markers.

@objc
public protocol ChartMarkerProtocol
{
    
    /// Draws the ChartMarker on the given position on the given context
    func draw(context context: CGContext, point: CGPoint)
    
    /// This method enables a custom ChartMarker to update it's content everytime the MarkerView is redrawn according to the data entry it points to.
    ///
    /// - parameter highlight: the highlight object contains information about the highlighted value such as it's dataset-index, the selected range or stack-index (only stacked bar entries).
    func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    
    var size: CGSize { get }
}