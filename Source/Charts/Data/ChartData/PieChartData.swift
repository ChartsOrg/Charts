//
//  PieData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class PieChartData: ChartData {
    public required init() {
        super.init()
    }

    override public init(dataSets: [ChartDataSet]) {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSet...) {
        super.init(dataSets: elements)
    }

    public var dataSet: PieChartDataSet? {
        get {
            return dataSets.first as? PieChartDataSet
        }
        set {
            if let set = newValue {
                dataSets = [set]
            } else {
                dataSets = []
            }
        }
    }

    /// - returns: All up to one dataSet object this ChartData object holds.
    override open var dataSets: [ChartDataSet] {
        get {
            assert(super.dataSets.count <= 1, "Found multiple data sets while pie chart only allows one")
            return super.dataSets
        }
        set {
            super.dataSets = newValue
        }
    }

    override open func dataSet(at index: ChartData.Index) -> ChartData.Element? {
        guard index == 0 else { return nil }
        return self[index]
    }

    override open func dataSet(forLabel label: String, ignorecase: Bool) -> ChartDataSet? {
        if dataSets.first?.label == nil {
            return nil
        }

        if ignorecase {
            if let label = dataSets[0].label, label.caseInsensitiveCompare(label) == .orderedSame {
                return dataSets[0]
            }
        } else {
            if label == dataSets[0].label {
                return dataSets[0]
            }
        }
        return nil
    }

    override open func entry(for highlight: Highlight) -> ChartDataEntry? {
        dataSet?[Int(highlight.x)]
    }

    /// The total y-value sum across all DataSet objects the this object represents.
    open var yValueSum: Double {
        guard let dataSet = dataSet else { return 0.0 }
        return dataSet.reduce(into: 0) {
            $0 += $1.y
        }
    }
}
