//
//  PieChartView.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

/// View that represents a pie chart. Draws cake like slices.
open class PieChartView: PieRadarChartViewBase
{
    /// rect object that represents the bounds of the piechart, needed for drawing the circle
    fileprivate var _circleBox = CGRect()

    /// array that holds the width of each pie-slice in degrees
    fileprivate var _drawAngles = [CGFloat]()
    
    /// array that holds the absolute angle in degrees of each slice
    fileprivate var _absoluteAngles = [CGFloat]()

    fileprivate var _holeColor: NSUIColor? = NSUIColor.white
    
    /// Sets the color the entry labels are drawn with.
    fileprivate var _entryLabelColor: NSUIColor? = NSUIColor.white
    
    /// Sets the font the entry labels are drawn with.
    fileprivate var _entryLabelFont: NSUIFont? = NSUIFont(name: "HelveticaNeue", size: 13.0)

    /// variable for the text that is drawn in the center of the pie-chart
    fileprivate var _centerAttributedText: NSAttributedString?
    
    /// the offset on the x- and y-axis the center text has in dp.
    fileprivate var _centerTextOffset: CGPoint = CGPoint()
    
    /// indicates the size of the hole in the center of the piechart
    ///
    /// **default**: `0.5`
    fileprivate var _holeRadiusPercent = CGFloat(0.5)
    
    fileprivate var _transparentCircleColor: NSUIColor? = NSUIColor(white: 1.0, alpha: 105.0/255.0)
    
    /// the radius of the transparent circle next to the chart-hole in the center
    fileprivate var _transparentCircleRadiusPercent = CGFloat(0.55)

    fileprivate var _centerTextRadiusPercent: CGFloat = 1.0
    
    /// maximum angle for this pie
    fileprivate var _maxAngle: CGFloat = 360.0

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
        _xAxis = nil
        
        self.highlighter = PieHighlighter(chart: self)
    }
    
    open override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        if _data === nil
        {
            return
        }
        
        let optionalContext = NSUIGraphicsGetCurrentContext()
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
        calcAngles()
    }
    
    open override func getMarkerPosition(highlight: Highlight) -> CGPoint
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
        
        let entryIndex = Int(highlight.x)
        
        // offset needed to center the drawn text in the slice
        let offset = drawAngles[entryIndex] / 2.0
        
        // calculate the text position
        let x: CGFloat = (r * cos(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(_animator.phaseY)) * ChartUtils.Math.FDEG2RAD) + center.x)
        let y: CGFloat = (r * sin(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(_animator.phaseY)) * ChartUtils.Math.FDEG2RAD) + center.y)
        
        return CGPoint(x: x, y: y)
    }
    
    /// calculates the needed angles for the chart slices
    fileprivate func calcAngles()
    {
        _drawAngles = [CGFloat]()
        _absoluteAngles = [CGFloat]()
        
        guard let data = _data else { return }

        let entryCount = data.entryCount
        
        _drawAngles.reserveCapacity(entryCount)
        _absoluteAngles.reserveCapacity(entryCount)
        
        let yValueSum = (_data as! PieChartData).yValueSum
        
        var dataSets = data.dataSets

        var cnt = 0

        for i in 0 ..< data.dataSetCount
        {
            let set = dataSets[i]
            let entryCount = set.entryCount

            for j in 0 ..< entryCount
            {
                guard let e = set.entryForIndex(j) else { continue }
                
                _drawAngles.append(calcAngle(value: abs(e.y), yValueSum: yValueSum))

                if cnt == 0
                {
                    _absoluteAngles.append(_drawAngles[cnt])
                }
                else
                {
                    _absoluteAngles.append(_absoluteAngles[cnt - 1] + _drawAngles[cnt])
                }

                cnt += 1
            }
        }
    }
    
    /// Checks if the given index is set to be highlighted.
    @objc open func needsHighlight(index: Int) -> Bool
    {
        // no highlight
        if !valuesToHighlight()
        {
            return false
        }
        
        for i in 0 ..< _indicesToHighlight.count
        {
            // check if the xvalue for the given dataset needs highlight
            if Int(_indicesToHighlight[i].x) == index
            {
                return true
            }
        }
        
        return false
    }
    
    /// calculates the needed angle for a given value
    fileprivate func calcAngle(_ value: Double) -> CGFloat
    {
        return calcAngle(value: value, yValueSum: (_data as! PieChartData).yValueSum)
    }
    
    /// calculates the needed angle for a given value
    fileprivate func calcAngle(value: Double, yValueSum: Double) -> CGFloat
    {
        return CGFloat(value) / CGFloat(yValueSum) * _maxAngle
    }
    
    /// This will throw an exception, PieChart has no XAxis object.
    open override var xAxis: XAxis
    {
        fatalError("PieChart has no XAxis")
    }
    
    open override func indexForAngle(_ angle: CGFloat) -> Int
    {
        // take the current angle of the chart into consideration
        let a = ChartUtils.normalizedAngleFromAngle(angle - self.rotationAngle)
        for i in 0 ..< _absoluteAngles.count
        {
            if _absoluteAngles[i] > a
            {
                return i
            }
        }
        
        return -1 // return -1 if no index found
    }
    
    /// - returns: The index of the DataSet this x-index belongs to.
    @objc open func dataSetIndexForIndex(_ xValue: Double) -> Int
    {
        var dataSets = _data?.dataSets ?? []
        
        for i in 0 ..< dataSets.count
        {
            if (dataSets[i].entryForXValue(xValue, closestToY: Double.nan) !== nil)
            {
                return i
            }
        }
        
        return -1
    }
    
    /// - returns: An integer array of all the different angles the chart slices
    /// have the angles in the returned array determine how much space (of 360°)
    /// each slice takes
    @objc open var drawAngles: [CGFloat]
    {
        return _drawAngles
    }

    /// - returns: The absolute angles of the different chart slices (where the
    /// slices end)
    @objc open var absoluteAngles: [CGFloat]
    {
        return _absoluteAngles
    }
    
    /// The color for the hole that is drawn in the center of the PieChart (if enabled).
    /// 
    /// - note: Use holeTransparent with holeColor = nil to make the hole transparent.*
    @objc open var holeColor: NSUIColor?
    {
        get
        {
            return _holeColor
        }
        set
        {
            _holeColor = newValue
            setNeedsDisplay()
        }
    }
    
    /// if true, the hole will see-through to the inner tips of the slices
    ///
    /// **default**: `false`
    /// - returns: `true` if the inner tips of the slices are visible behind the hole, `false` if not.
    @objc public var isDrawSlicesUnderHoleEnabled: Bool {
        get { return _isDrawSlicesUnderHoleEnabled }
        @objc(setDrawSlicesUnderHoleEnabled:) set {
            _isDrawSlicesUnderHoleEnabled = newValue
            setNeedsDisplay()
        }
    }
    private var _isDrawSlicesUnderHoleEnabled = false
    
    /// `true` if the hole in the center of the pie-chart is set to be visible, `false` ifnot
    /// if true, the hole inside the chart will be drawn
    /// - returns: `true` if the hole in the center of the pie-chart is set to be visible, `false` ifnot
    @objc public var isDrawHoleEnabled: Bool {
        get { return _isDrawHoleEnabled }
        @objc(setDrawHoleEnabled:) set {
            _isDrawHoleEnabled = newValue
            setNeedsDisplay()
        }
    }
    private var _isDrawHoleEnabled = true

    /// the text that is displayed in the center of the pie-chart
    @objc open var centerText: String?
    {
        get
        {
            return self.centerAttributedText?.string
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
                #if os(OSX)
                    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    paragraphStyle.lineBreakMode = NSParagraphStyle.LineBreakMode.byTruncatingTail
                #else
                    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                #endif
                paragraphStyle.alignment = .center
                
                attrString = NSMutableAttributedString(string: newValue!)
                attrString?.setAttributes([
                    NSAttributedStringKey.foregroundColor: NSUIColor.black,
                    NSAttributedStringKey.font: NSUIFont.systemFont(ofSize: 12.0),
                    NSAttributedStringKey.paragraphStyle: paragraphStyle
                    ], range: NSMakeRange(0, attrString!.length))
            }
            self.centerAttributedText = attrString
        }
    }
    
    /// the text that is displayed in the center of the pie-chart
    @objc open var centerAttributedText: NSAttributedString?
    {
        get
        {
            return _centerAttributedText
        }
        set
        {
            _centerAttributedText = newValue
            setNeedsDisplay()
        }
    }
    
    /// Sets the offset the center text should have from it's original position in dp. Default x = 0, y = 0
    @objc open var centerTextOffset: CGPoint
    {
        get
        {
            return _centerTextOffset
        }
        set
        {
            _centerTextOffset = newValue
            setNeedsDisplay()
        }
    }

    /// if enabled, centertext is drawn
    /// `true` if drawing the center text is enabled
    /// - returns: `true` if drawing the center text is enabled
    @objc public var isDrawCenterTextEnabled: Bool {
        get { return _isDrawCenterTextEnabled }
        @objc(setDrawCenterTextEnabled:) set {
            _isDrawCenterTextEnabled = newValue
            setNeedsDisplay()
        }
    }
    private var _isDrawCenterTextEnabled = true

    internal override var requiredLegendOffset: CGFloat
    {
        return _legend.font.pointSize * 2.0
    }
    
    internal override var requiredBaseOffset: CGFloat
    {
        return 0.0
    }
    
    open override var radius: CGFloat
    {
        return _circleBox.width / 2.0
    }
    
    /// - returns: The circlebox, the boundingbox of the pie-chart slices
    @objc open var circleBox: CGRect
    {
        return _circleBox
    }
    
    /// - returns: The center of the circlebox
    @objc open var centerCircleBox: CGPoint
    {
        return CGPoint(x: _circleBox.midX, y: _circleBox.midY)
    }
    
    /// the radius of the hole in the center of the piechart in percent of the maximum radius (max = the radius of the whole chart)
    /// 
    /// **default**: 0.5 (50%) (half the pie)
    @objc open var holeRadiusPercent: CGFloat
    {
        get
        {
            return _holeRadiusPercent
        }
        set
        {
            _holeRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
    
    /// The color that the transparent-circle should have.
    ///
    /// **default**: `nil`
    @objc open var transparentCircleColor: NSUIColor?
    {
        get
        {
            return _transparentCircleColor
        }
        set
        {
            _transparentCircleColor = newValue
            setNeedsDisplay()
        }
    }
    
    /// the radius of the transparent circle that is drawn next to the hole in the piechart in percent of the maximum radius (max = the radius of the whole chart)
    /// 
    /// **default**: 0.55 (55%) -> means 5% larger than the center-hole by default
    @objc open var transparentCircleRadiusPercent: CGFloat
    {
        get
        {
            return _transparentCircleRadiusPercent
        }
        set
        {
            _transparentCircleRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
    
    /// set this to true to draw the enrty labels into the pie slices
    @objc @available(*, deprecated: 1.0, message: "Use `drawEntryLabelsEnabled` instead.")
    open var drawSliceTextEnabled: Bool
    {
        get
        {
            return isDrawEntryLabelsEnabled
        }
        set
        {
            isDrawEntryLabelsEnabled = newValue
        }
    }
    
    /// - returns: `true` if drawing entry labels is enabled, `false` ifnot
    @objc @available(*, deprecated: 1.0, message: "Use `isDrawEntryLabelsEnabled` instead.")
    open var isDrawSliceTextEnabled: Bool
    {
        get
        {
            return isDrawEntryLabelsEnabled
        }
    }
    
    /// The color the entry labels are drawn with.
    @objc open var entryLabelColor: NSUIColor?
    {
        get { return _entryLabelColor }
        set
        {
            _entryLabelColor = newValue
            setNeedsDisplay()
        }
    }
    
    /// The font the entry labels are drawn with.
    @objc open var entryLabelFont: NSUIFont?
    {
        get { return _entryLabelFont }
        set
        {
            _entryLabelFont = newValue
            setNeedsDisplay()
        }
    }
    
    /// Set this to true to draw the enrty labels into the pie slices
    /// - returns: `true` if drawing entry labels is enabled, `false` ifnot
    /// flag indicating if entry labels should be drawn or not
    @objc public var isDrawEntryLabelsEnabled: Bool {
        get { return _isDrawEntryLabelsEnabled }
        @objc(setDrawEntryLabelsEnabled:) set {
            _isDrawEntryLabelsEnabled = newValue
            setNeedsDisplay()
        }
    }
    private var _isDrawEntryLabelsEnabled = true

    /// if true, the values inside the piechart are drawn as percent values
    /// If this is enabled, values inside the PieChart are drawn in percent and not with their original value. Values provided for the ValueFormatter to format are then provided in percent.
    /// - returns: `true` if drawing x-values is enabled, `false` ifnot
    @objc public var isUsePercentValuesEnabled: Bool {
        get { return _isUsePercentValuesEnabled }
        @objc(setUsePercentValuesEnabled:) set {
            _isUsePercentValuesEnabled = newValue
            setNeedsDisplay()
        }
    }
    private var _isUsePercentValuesEnabled = false

    
    /// the rectangular radius of the bounding box for the center text, as a percentage of the pie hole
    @objc open var centerTextRadiusPercent: CGFloat
    {
        get
        {
            return _centerTextRadiusPercent
        }
        set
        {
            _centerTextRadiusPercent = newValue
            setNeedsDisplay()
        }
    }
    
    /// The max angle that is used for calculating the pie-circle.
    /// 360 means it's a full pie-chart, 180 results in a half-pie-chart.
    /// **default**: 360.0
    @objc open var maxAngle: CGFloat
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
