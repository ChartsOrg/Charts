//
//  OHLCChartDataProvider.swift
//  Charts
//
//  Created by John Casley on 10/22/15.
//  Copyright © 2015 John Casley. All rights reserved.
//

import Foundation
import CoreGraphics

@objc
public protocol OHLCChartDataProvider: BarLineScatterCandleBubbleChartDataProvider {
    var ohlcData: OHLCChartData? { get }
}
