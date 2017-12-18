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
    /// The boundingbox of the pie-chart slices
    /// rect object that represents the bounds of the piechart, needed for drawing the circle
    @objc open private(set) var circleBox = CGRect()

    /// flag indicating if entry labels should be drawn or not
    private var _drawEntryLabelsEnabled = true
    
    /// - returns: An integer array of all the different angles the chart slices
    /// have the angles in the returned array determine how much space (of 360°)
    /// each slice takes
    @objc open private(set) var drawAngles = [CGFloat]()
    
    /// - returns: The absolute angles of the different chart slices (where the
    /// slices end)
    @objc open private(set) var absoluteAngles = [CGFloat]()
    
    /// if true, the hole inside the chart will be drawn
    private var _drawHoleEnabled = true
    
    /// The color for the hole that is drawn in the center of the PieChart (if enabled).
    ///
    /// - note: Use holeTransparent with holeColor = nil to make the hole transparent.*
    @objc open var holeColor: NSUIColor? = .white {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The color the entry labels are drawn with.
    @objc open var entryLabelColor: NSUIColor? = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The font the entry labels are drawn with.
    @objc open var entryLabelFont: NSUIFont? = NSUIFont(name: "HelveticaNeue", size: 13.0) {
        didSet {
            setNeedsDisplay()
        }
    }

    /// if true, the hole will see-through to the inner tips of the slices
    private var _drawSlicesUnderHoleEnabled = false
    
    /// if true, the values inside the piechart are drawn as percent values
    private var _usePercentValuesEnabled = false
    
    /// the text that is displayed in the center of the pie-chart
    @objc open var centerAttributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Sets the offset the center text should have from it's original position in dp. Default x = 0, y = 0
    @objc open var centerTextOffset: CGPoint = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    /// the radius of the hole in the center of the piechart in percent of the maximum radius (max = the radius of the whole chart)
    ///
    /// **default**: 0.5 (50%) (half the pie)
    @objc open var holeRadiusPercent: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The color that the transparent-circle should have.
    ///
    /// **default**: `nil`
    @objc open var transparentCircleColor: NSUIColor? = NSUIColor(white: 1.0, alpha: 105.0/255.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// the radius of the transparent circle that is drawn next to the hole in the piechart in percent of the maximum radius (max = the radius of the whole chart)
    ///
    /// **default**: 0.55 (55%) -> means 5% larger than the center-hole by default
    @objc open var transparentCircleRadiusPercent: CGFloat = 0.55 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// if enabled, centertext is drawn
    private var _drawCenterTextEnabled = true
    
    /// the rectangular radius of the bounding box for the center text, as a percentage of the pie hole
    @objc open var centerTextRadiusPercent: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }

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
        guard let context = optionalContext, let renderer = renderer else
        {
            return
        }
        
        renderer.drawData(context: context)
        
        if (valuesToHighlight())
        {
            renderer.drawHighlighted(context: context, indices: _indicesToHighlight)
        }
        
        renderer.drawExtras(context: context)
        
        renderer.drawValues(context: context)
        
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
        circleBox.origin.x = (c.x - radius) + shift
        circleBox.origin.y = (c.y - radius) + shift
        circleBox.size.width = diameter - shift * 2.0
        circleBox.size.height = diameter - shift * 2.0
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
        let x: CGFloat = (r * cos(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(_animator.phaseY)).DEG2RAD) + center.x)
        let y: CGFloat = (r * sin(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(_animator.phaseY)).DEG2RAD) + center.y)
        
        return CGPoint(x: x, y: y)
    }
    
    /// calculates the needed angles for the chart slices
    private func calcAngles()
    {
        drawAngles = [CGFloat]()
        absoluteAngles = [CGFloat]()
        
        guard let data = _data else { return }

        let entryCount = data.entryCount
        
        drawAngles.reserveCapacity(entryCount)
        absoluteAngles.reserveCapacity(entryCount)
        
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
                
                drawAngles.append(calcAngle(value: abs(e.y), yValueSum: yValueSum))

                if cnt == 0
                {
                    absoluteAngles.append(drawAngles[cnt])
                }
                else
                {
                    absoluteAngles.append(absoluteAngles[cnt - 1] + drawAngles[cnt])
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
    private func calcAngle(_ value: Double) -> CGFloat
    {
        return calcAngle(value: value, yValueSum: (_data as! PieChartData).yValueSum)
    }
    
    /// calculates the needed angle for a given value
    private func calcAngle(value: Double, yValueSum: Double) -> CGFloat
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
        let a = (angle - self.rotationAngle).normalizedAngle
        for i in 0 ..< absoluteAngles.count
        {
            if absoluteAngles[i] > a
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
    
    /// if true, the hole will see-through to the inner tips of the slices
    ///
    /// **default**: `false`
    @objc open var drawSlicesUnderHoleEnabled: Bool
    {
        get
        {
            return _drawSlicesUnderHoleEnabled
        }
        set
        {
            _drawSlicesUnderHoleEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if the inner tips of the slices are visible behind the hole, `false` if not.
    @objc open var isDrawSlicesUnderHoleEnabled: Bool
    {
        return drawSlicesUnderHoleEnabled
    }
    
    /// `true` if the hole in the center of the pie-chart is set to be visible, `false` ifnot
    @objc open var drawHoleEnabled: Bool
    {
        get
        {
            return _drawHoleEnabled
        }
        set
        {
            _drawHoleEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if the hole in the center of the pie-chart is set to be visible, `false` ifnot
    @objc open var isDrawHoleEnabled: Bool
    {
        get
        {
            return drawHoleEnabled
        }
    }
    
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
    
    /// `true` if drawing the center text is enabled
    @objc open var drawCenterTextEnabled: Bool
    {
        get
        {
            return _drawCenterTextEnabled
        }
        set
        {
            _drawCenterTextEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if drawing the center text is enabled
    @objc open var isDrawCenterTextEnabled: Bool
    {
        get
        {
            return drawCenterTextEnabled
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
    
    open override var radius: CGFloat
    {
        return circleBox.width / 2.0
    }
    
    /// - returns: The center of the circlebox
    @objc open var centerCircleBox: CGPoint
    {
        return CGPoint(x: circleBox.midX, y: circleBox.midY)
    }
    
    /// Set this to true to draw the enrty labels into the pie slices
    @objc open var drawEntryLabelsEnabled: Bool
    {
        get
        {
            return _drawEntryLabelsEnabled
        }
        set
        {
            _drawEntryLabelsEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if drawing entry labels is enabled, `false` ifnot
    @objc open var isDrawEntryLabelsEnabled: Bool
    {
        get
        {
            return drawEntryLabelsEnabled
        }
    }
    
    /// If this is enabled, values inside the PieChart are drawn in percent and not with their original value. Values provided for the ValueFormatter to format are then provided in percent.
    @objc open var usePercentValuesEnabled: Bool
    {
        get
        {
            return _usePercentValuesEnabled
        }
        set
        {
            _usePercentValuesEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: `true` if drawing x-values is enabled, `false` ifnot
    @objc open var isUsePercentValuesEnabled: Bool
    {
        get
        {
            return usePercentValuesEnabled
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
