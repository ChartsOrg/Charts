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

    override public init(dataSets: [ChartDataSetProtocol]) {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSetProtocol...) {
        super.init(dataSets: elements)
    }

    public var dataSet: PieChartDataSetProtocol? {
        get {
            return dataSets.first as? PieChartDataSetProtocol
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
    override open var dataSets: [ChartDataSetProtocol] {
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

    override open func dataSet(forLabel label: String, ignorecase: Bool) -> ChartDataSetProtocol? {
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
        return dataSet?.entryForIndex(Int(highlight.x))
    }

    /// The total y-value sum across all DataSet objects the this object represents.
    open var yValueSum: Double {
        guard let dataSet = dataSet else { return 0.0 }
        return (0 ..< dataSet.entryCount).reduce(into: 0) {
            $0 += dataSet.entryForIndex($1)?.y ?? 0
        }
    }
}