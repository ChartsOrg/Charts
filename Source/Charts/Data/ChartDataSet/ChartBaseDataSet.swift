//
//  BaseDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

protocol ChartBaseDataSet: ChartDataSetProtocol {

}

extension ChartDataSetProtocol {
    /// Use this method to tell the data set that the underlying data has changed
    public func notifyDataSetChanged() {
        calcMinMax()
    }

    @discardableResult
    public func removeEntry(x: Double) -> Bool {
        if let entry = entryForXValue(x, closestToY: Double.nan) {
            return remove(entry)
        }
        return false
    }
}
