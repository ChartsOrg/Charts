//
//  PieChartView.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

/// View that represents a pie chart. Draws cake like slices.
public class PieChartView: PieRadarChartViewBase
{
    /// rect object that represents the bounds of the piechart, needed for drawing the circle
    private var _circleBox = CGRect()
    
    /// array that holds the width of each pie-slice in degrees
    private var _drawAngles = [CGFloat]()
    
    /// array that holds the absolute angle in degrees of each slice
    private var _absoluteAngles = [CGFloat]()
    
    /// maximum angle for this pie
    private var _maxAngle: CGFloat = 360.0

    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    internal override func initialize()
    {
        super.initialize()
        
        renderer = PieChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    public override func drawRect(rect: CGRect)
    {
        super.drawRect(rect)
        
        if _data === nil
        {
            return
        }
        
        let optionalContext = UIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        renderer!.drawData(context: context)
        
        if (valuesToHighlight())
        {
            renderer!.drawHighlighted(context: context, indices: _indicesToHighlight)
        }
        
        renderer!.drawExtras(context: context)
        
        renderer!.drawValues(context: context)
        
        _legendRenderer.renderLegend(context: context)
        
        drawDescription(context: context)
        
        drawMarkers(context: context)
    }
    
    internal override func calculateOffsets()
    {
        super.calculateOffsets()
        
        // prevent nullpointer when no data set
        if _data === nil
        {
            return
        }
        
        let radius = diameter / 2.0
        
        let c = self.centerOffsets
        
        let shift = (data as? PieChartData)?.dataSet?.selectionShift ?? 0.0
        
        // create the circle box that will contain the pie-chart (the bounds of the pie-chart)
        _circleBox.origin.x = (c.x - radius) + shift
        _circleBox.origin.y = (c.y - radius) + shift
        _circleBox.size.width = diameter - shift * 2.0
        _circleBox.size.height = diameter - shift * 2.0
    }
    
    internal override func calcMinMax()
    {
        super.calcMinMax()
        
        calcAngles()
    }
    
    public override func getMarkerPosition(entry e: ChartDataEntry, highlight: ChartHighlight) -> CGPoint
    {
        let center = self.centerCircleBox
        var r = self.radius
        
        var off = r / 10.0 * 3.6
        
        if self.isDrawHoleEnabled
        {
            off = (r - (r * self.holeRadiusPercent)) / 2.0
        }
        
        r -= off // offset to keep things inside the chart
        
        let rotationAngle = self.rotationAngle
        
        let i = e.xIndex
        
        // offset needed to center the drawn text in the slice
        let offset = drawAngles[i] / 2.0
        
        // calculate the text position
        let x: CGFloat = (r * cos(((rotationAngle + absoluteAngles[i] - offset) * _animator.phaseY) * ChartUtils.Math.FDEG2RAD) + center.x)
        let y: CGFloat = (r * sin(((rotationAngle + absoluteAngles[i] - offset) * _animator.phaseY) * ChartUtils.Math.FDEG2RAD) + center.y)
        
        return CGPoint(x: x, y: y)
    }
    
    /// calculates the needed angles for the chart slices
    private func calcAngles()
    {
        _drawAngles = [CGFloat]()
        _absoluteAngles = [CGFloat]()
        
        _drawAngles.reserveCapacity(_data.yValCount)
        _absoluteAngles.reserveCapacity(_data.yValCount)
        
        let yValueSum = (_data as! PieChartData).yValueSum
        
        var dataSets = _data.dataSets

        var cnt = 0

        for (var i = 0; i < _data.dataSetCount; i++)
        {
            let set = dataSets[i]
            let entryCount = set.entryCount

            for (var j = 0; j < entryCount; j++)
            {
                guard let e = set.entryForIndex(j) else { continue }
                
                _drawAngles.append(calcAngle(abs(e.value), yValueSum: yValueSum))

                if (cnt == 0)
                {
                    _absoluteAngles.append(_drawAngles[cnt])
                }
                else
                {
                    _absoluteAngles.append(_absoluteAngles[cnt - 1] + _drawAngles[cnt])
                }

                cnt++
            }
        }
    }
    
    /// checks if the given index in the given DataSet is set for highlighting or not
    public func needsHighlight(xIndex xIndex: Int, dataSetIndex: Int) -> Bool
    {
        // no highlight
        if (!valuesToHighlight() || dataSetIndex < 0)
        {
            return false
        }
        
        for (var i = 0; i < _indicesToHighlight.count; i++)
        {
            // check if the xvalue for the given dataset needs highlight
            if (_indicesToHighlight[i].xIndex == xIndex
                && _indicesToHighlight[i].dataSetIndex == dataSetIndex)
            {
                return true
            }
        }
        
        return false
    }
    
    /// calculates the needed angle for a given value
    private func calcAngle(value: Double) -> CGFloat
    {
        return calcAngle(value, yValueSum: (_data as! PieChartData).yValueSum)
    }
    
    /// calculates the needed angle for a given value
    private func calcAngle(value: Double, yValueSum: Double) -> CGFloat
    {
        return CGFloat(value) / CGFloat(yValueSum) * _maxAngle
    }
    
    public override func indexForAngle(angle: CGFloat) -> Int
    {
        // take the current angle of the chart into consideration
        let a = ChartUtils.normalizedAngleFromAngle(angle - self.rotationAngle)
        for (var i = 0; i < _absoluteAngles.count; i++)
        {
            if (_absoluteAngles[i] > a)
            {
                return i
            }
        }
        
        return -1; // return -1 if no index found
    }
    
    /// - returns: the index of the DataSet this x-index belongs to.
    public func dataSetIndexForIndex(xIndex: Int) -> Int
    {
        var dataSets = _data.dataSets
        
        for (var i = 0; i < dataSets.count; i++)
        {
            if (dataSets[i].entryForXIndex(xIndex) !== nil)
            {
                return i
            }
        }
        
        return -1
    }
    
    /// - returns: an integer array of all the different angles the chart slices
    /// have the angles in the returned array determine how much space (of 360°)
    /// each slice takes
    public var drawAngles: [CGFloat]
    {
        return _drawAngles
    }

    /// - returns: the absolute angles of the different chart slices (where the
    /// slices end)
    public var absoluteAngles: [CGFloat]
    {
        return _absoluteAngles
    }
    
    /// Sets the color for the hole that is drawn in the center of the PieChart (if enabled).
    /// 
    /// *Note: Use holeTransparent with holeColor = nil to make the hole transparent.*
    public var holeColor: UIColor?
    {
        get
        {
            return (renderer as? PieChartRenderer)?.holeColor
        }
        set
        {
            (renderer as? PieChartRenderer)?.holeColor = newValue
            setNeedsDisplay()
        }
    }
    
    /// Set the hole in the center of the PieChart transparent
    public var holeTransparent: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).holeTransparent
        }
        set
        {
            (renderer as! PieChartRenderer).holeTransparent = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: true if the hole in the center of the PieChart is transparent, false if not.
    public var isHoleTransparent: Bool 
    {
        return (renderer as! PieChartRenderer).holeTransparent
    }
    
    /// the alpha of the hole in the center of the piechart, in case holeTransparent == true
    ///
    /// **default**: 0.41
    public var holeAlpha: CGFloat
    {
        get
        {
            return (renderer as! PieChartRenderer).holeAlpha
        }
        set
        {
            (renderer as! PieChartRenderer).holeAlpha = newValue
            setNeedsDisplay()
        }
    }
    
    /// true if the hole in the center of the pie-chart is set to be visible, false if not
    public var drawHoleEnabled: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).drawHoleEnabled
        }
        set
        {
            (renderer as! PieChartRenderer).drawHoleEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: true if the hole in the center of the pie-chart is set to be visible, false if not
    public var isDrawHoleEnabled: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).drawHoleEnabled
        }
    }
    
    /// the text that is displayed in the center of the pie-chart
    public var centerText: String?
    {
        get
        {
            return (renderer as! PieChartRenderer).centerAttributedText?.string
        }
        set
        {
            var attrString: NSMutableAttributedString?
            if newValue == nil
            {
                attrString = nil
            }
            else
            {
                let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                paragraphStyle.alignment = .Center
                
                attrString = NSMutableAttributedString(string: newValue!)
                attrString?.setAttributes([
                    NSForegroundColorAttributeName: UIColor.blackColor(),
                    NSFontAttributeName: UIFont.systemFontOfSize(12.0),
                    NSParagraphStyleAttributeName: paragraphStyle
                    ], range: NSMakeRange(0, attrString!.length))
            }
            (renderer as! PieChartRenderer).centerAttributedText = attrString
            setNeedsDisplay()
        }
    }
    
    /// the text that is displayed in the center of the pie-chart
    public var centerAttributedText: NSAttributedString?
    {
        get
        {
            return (renderer as! PieChartRenderer).centerAttributedText
        }
        set
        {
            (renderer as! PieChartRenderer).centerAttributedText = newValue
            setNeedsDisplay()
        }
    }
    
    /// true if drawing the center text is enabled
    public var drawCenterTextEnabled: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).drawCenterTextEnabled
        }
        set
        {
            (renderer as! PieChartRenderer).drawCenterTextEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: true if drawing the center text is enabled
    public var isDrawCenterTextEnabled: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).drawCenterTextEnabled
        }
    }
    
    internal override var requiredLegendOffset: CGFloat
    {
        return _legend.font.pointSize * 2.0
    }
    
    internal override var requiredBaseOffset: CGFloat
    {
        return 0.0
    }
    
    public override var radius: CGFloat
    {
        return _circleBox.width / 2.0
    }
    
    /// - returns: the circlebox, the boundingbox of the pie-chart slices
    public var circleBox: CGRect
    {
        return _circleBox
    }
    
    /// - returns: the center of the circlebox
    public var centerCircleBox: CGPoint
    {
        return CGPoint(x: _circleBox.midX, y: _circleBox.midY)
    }
    
    /// the radius of the hole in the center of the piechart in percent of the maximum radius (max = the radius of the whole chart)
    /// 
    /// **default**: 0.5 (50%) (half the pie)
    public var holeRadiusPercent: CGFloat
    {
        get
        {
            return (renderer as! PieChartRenderer).holeRadiusPercent
        }
        set
        {
            (renderer as! PieChartRenderer).holeRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
    
    /// the radius of the transparent circle that is drawn next to the hole in the piechart in percent of the maximum radius (max = the radius of the whole chart)
    /// 
    /// **default**: 0.55 (55%) -> means 5% larger than the center-hole by default
    public var transparentCircleRadiusPercent: CGFloat
    {
        get
        {
            return (renderer as! PieChartRenderer).transparentCircleRadiusPercent
        }
        set
        {
            (renderer as! PieChartRenderer).transparentCircleRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
    
    /// set this to true to draw the x-value text into the pie slices
    public var drawSliceTextEnabled: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).drawXLabelsEnabled
        }
        set
        {
            (renderer as! PieChartRenderer).drawXLabelsEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: true if drawing x-values is enabled, false if not
    public var isDrawSliceTextEnabled: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).drawXLabelsEnabled
        }
    }
    
    /// If this is enabled, values inside the PieChart are drawn in percent and not with their original value. Values provided for the ValueFormatter to format are then provided in percent.
    public var usePercentValuesEnabled: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).usePercentValuesEnabled
        }
        set
        {
            (renderer as! PieChartRenderer).usePercentValuesEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: true if drawing x-values is enabled, false if not
    public var isUsePercentValuesEnabled: Bool
    {
        get
        {
            return (renderer as! PieChartRenderer).usePercentValuesEnabled
        }
    }
    
    /// the rectangular radius of the bounding box for the center text, as a percentage of the pie hole
    public var centerTextRadiusPercent: CGFloat
    {
        get
        {
            return (renderer as! PieChartRenderer).centerTextRadiusPercent
        }
        set
        {
            (renderer as! PieChartRenderer).centerTextRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
    
    /// The max angle that is used for calculating the pie-circle.
    /// 360 means it's a full pie-chart, 180 results in a half-pie-chart.
    /// - default: 360.0
    public var maxAngle: CGFloat
    {
        get
        {
            return _maxAngle
        }
        set
        {
            _maxAngle = newValue
            
            if _maxAngle > 360.0
            {
                _maxAngle = 360.0
            }
            
            if _maxAngle < 90.0
            {
                _maxAngle = 90.0
            }
        }
    }
}