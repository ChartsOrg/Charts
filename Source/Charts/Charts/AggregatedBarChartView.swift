//
//  AggregatedBarChartView.swift
//  Charts
//
//  Created by Maxim Komlev on 5/5/17.
//
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

/// Chart that draws aggregate bars.
open class AggregatedBarChartView: BarChartView, AggregatedBarChartDataProvider {

    private let _groupMarginDef: CGFloat = 6
    private let _groupWidthDef: CGFloat = 10
    
    internal var _groupMargin: CGFloat = 0.0
    internal var _groupWidth: CGFloat = 0.0

    internal override func initialize()
    {
        super.initialize()
        
        _groupMargin = _groupMarginDef
        _groupWidth = _groupWidthDef
        
        renderer = AggregatedBarChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        highlighter = AggregatedBarHighlighter(chart: self)
    }
    
    public var groupMargin: CGFloat {
        get {
            return _groupMargin
        } set (v) {
            _groupMargin = v
        }
    }

    public var groupWidth: CGFloat {
        get {
            return _groupWidth
        } set (v) {
            _groupWidth = v
        }
    }

    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        let val = (highlighter as! AggregatedBarHighlighter).getValsForTouch(x: pt.x, y: pt.y)
        guard let dsIndex = (self.renderer as! AggregatedBarChartRenderer).findDataEntryAt(x: pt.x, y: pt.y)
            else { return nil }
        
        // For isHighlightFullBarEnabled, remove stackIndex
        return Highlight(x: Double(val.x), y: Double(val.y), xPx: pt.x, yPx: pt.y,
                         dataIndex: dsIndex.dataEntryIndex, dataSetIndex: dsIndex.dataSetIndex, stackIndex: -1,
                         axis: YAxis.AxisDependency.left)
    }

    /// Highlights the value selected by touch gesture.
    open override func highlightValue(_ highlight: Highlight?, callDelegate: Bool)
    {
        var entry: ChartDataEntry?
        var h = highlight
        
        if h == nil
        {
            _indicesToHighlight.removeAll(keepingCapacity: false)
        }
        else
        {
            // set the indices to highlight
            entry = _data?.entryForHighlight(h!)
            if entry == nil
            {
                h = nil
                _indicesToHighlight.removeAll(keepingCapacity: false)
            }
            else
            {
                _indicesToHighlight = [h!]
            }
        }
        
        if callDelegate && delegate != nil
        {
            if h == nil
            {
                delegate!.chartValueNothingSelected?(self)
            }
            else
            {
                // notify the listener
                delegate!.chartValueSelected?(self, entry: entry!, highlight: h!)
            }
        }
        
        // redraw the chart
        setNeedsDisplay()
    }

}
