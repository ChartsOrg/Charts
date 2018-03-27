//
//  DataSet.swift
//  Charts
//
//  Created by Jacob Christie on 2018-03-19.
//

import Foundation

public struct DataSetStyle: DataSetStyleOptions {
    
    public var valueColors: [NSUIColor]

    public var colors: [NSUIColor]

    public var iconsOffset: CGPoint

    public var valueFormatter: ValueFormatter

    public var valueTextColor: NSUIColor

    public var valueFont: NSUIFont

    public var form: Legend.Form

    public var formSize: CGFloat

    public var formLineWidth: CGFloat

    public var formLineDashPhase: CGFloat

    public var formLineDashLengths: [CGFloat]?
}

public struct DataSetDrawOptions: DataSetDrawingOptions {
    public var axisDependency: YAxis.AxisDependency

    public var isHighlightEnabled: Bool

    public var isDrawValuesEnabled: Bool

    public var isDrawIconsEnabled: Bool

    public var isVisible: Bool
}

public struct DataSet: DataSetProtocol {
    public func notifyDataSetChanged() {
        <#code#>
    }

    public func calcMinMax() {
        <#code#>
    }

    public func calcMinMaxY(fromX: Double, toX: Double) {
        <#code#>
    }

    public func entry(forXValue xValue: Double, closestToY yValue: Double, rounding: ChartDataSetRounding) -> ChartDataEntry? {
        <#code#>
    }

    public func entry(forXValue xValue: Double, closestToY yValue: Double) -> ChartDataEntry? {
        <#code#>
    }

    public func entries(forXValue xValue: Double) -> [ChartDataEntry] {
        <#code#>
    }

    public func entryIndex(x xValue: Double, closestToY yValue: Double, rounding: ChartDataSetRounding) -> Int {
        <#code#>
    }

    public func index(of element: DataSet.Element) -> Int? {
        <#code#>
    }

    public func addEntry(_ e: ChartDataEntry) -> Bool {
        <#code#>
    }

    public var yMin: Double

    public var yMax: Double

    public var count: Int

    public var label: String?

    public var style: DataSetStyle

    public var drawingOptions: DataSetDrawOptions

    public var elements: SortedArray<DataEntry>

    public init(arrayLiteral elements: DataEntry...) {
        self.elements = SortedArray(unsorted: elements)
    }
}
