//
//  Double+Charts.swift
//  Charts
//
//  Created by Azamat Kalmurzayev on 2/22/18.
//

import Foundation
public extension Double {
    /// Adjusts a current Double value for bounds with specified min and max
    /// - parameters:
    ///   - minVal: Lower bounds
    ///   - maxVal: Upper bounds
    /// - returns: Adjusted Double value
    public func adjustTo(minVal: Double, maxVal: Double) -> Double {
        if minVal...maxVal ~= self {
            return self;
        }
        if self < minVal { return minVal }
        return maxVal
    }
}
