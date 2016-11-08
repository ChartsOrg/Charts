//
//  PieChartInnerPercentageView.swift
//  Charts
//
//  Created by Peter-John Welcome on 2016/11/08.
//
//

import Foundation

import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

open class PieChartInnerPercentageView : PieChartView {
    
    
    fileprivate var _innerCirclePercentage: Double? = 0.0
    fileprivate var _postiveColor : UIColor?  = .green
    fileprivate var _negativeColor : UIColor?  = .red
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func initialize() {
        super.initialize()
        renderer = PieChartInnerPercentageCircleRenderer(innnerChart: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _xAxis = nil
        self.highlighter = PieHighlighter(chart: self)
    }
    
    public var innerCirclePercentage : Double {
        get{
            return _innerCirclePercentage!
        }
        set{
            _innerCirclePercentage = newValue
        }
    }
    
    public var postiveColor : UIColor {
        get{
            return _postiveColor!
        }
    }
    
    public var negativeColor : UIColor {
        get{
            return _negativeColor!
        }
    }
}
