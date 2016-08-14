//
//  ChartViewBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
//  Based on https://github.com/PhilJay/MPAndroidChart/commit/c42b880

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

@objc
public protocol ChartViewDelegate
{
    /// Called when a value has been selected inside the chart.
    /// - parameter entry: The selected Entry.
    /// - parameter highlight: The corresponding highlight object that contains information about the highlighted position such as dataSetIndex etc.
    optional func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    
    // Called when nothing has been selected or an "un-select" has been made.
    optional func chartValueNothingSelected(chartView: ChartViewBase)
    
    // Callbacks when the chart is scaled / zoomed via pinch zoom gesture.
    optional func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat)
    
    // Callbacks when the chart is moved / translated via drag gesture.
    optional func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat)
}

public class ChartViewBase: NSUIView, ChartDataProvider, AnimatorDelegate
{
    // MARK: - Properties
    
    /// - returns: The object representing all x-labels, this method can be used to
    /// acquire the XAxis object and modify it (e.g. change the position of the
    /// labels)
    public var xAxis: XAxis
    {
        return _xAxis
    }
    
    /// The default IValueFormatter that has been determined by the chart considering the provided minimum and maximum values.
    internal var _defaultValueFormatter: IValueFormatter? = DefaultValueFormatter(decimals: 0)
    
    /// object that holds all data that was originally set for the chart, before it was modified or any filtering algorithms had been applied
    internal var _data: ChartData?
    
    /// Flag that indicates if highlighting per tap (touch) is enabled
    private var _highlightPerTapEnabled = true
    
    /// If set to true, chart continues to scroll after touch up
    public var dragDecelerationEnabled = true
    
    /// Deceleration friction coefficient in [0 ; 1] interval, higher values indicate that speed will decrease slowly, for example if it set to 0, it will stop immediately.
    /// 1 is an invalid value, and will be converted to 0.999 automatically.
    private var _dragDecelerationFrictionCoef: CGFloat = 0.9
    
    /// Font object used for drawing the description text (by default in the bottom right corner of the chart)
    public var descriptionFont: NSUIFont? = NSUIFont(name: "HelveticaNeue", size: 9.0)
    
    /// Text color used for drawing the description text
    public var descriptionTextColor: NSUIColor? = NSUIColor.blackColor()
    
    /// Text align used for drawing the description text
    public var descriptionTextAlign: NSTextAlignment = NSTextAlignment.Right
    
    /// Custom position for the description text in pixels on the screen.
    public var descriptionTextPosition: CGPoint? = nil
    
    /// font object for drawing the information text when there are no values in the chart
    public var infoFont: NSUIFont! = NSUIFont(name: "HelveticaNeue", size: 12.0)
    public var infoTextColor: NSUIColor! = NSUIColor(red: 247.0/255.0, green: 189.0/255.0, blue: 51.0/255.0, alpha: 1.0) // orange
    
    /// description text that appears in the bottom right corner of the chart
    public var descriptionText = "Description"
    
    /// if true, units are drawn next to the values in the chart
    internal var _drawUnitInChart = false
    
    /// the object representing the labels on the x-axis
    internal var _xAxis: XAxis!
    
    /// the legend object containing all data associated with the legend
    internal var _legend: Legend!
    
    /// delegate to receive chart events
    public weak var delegate: ChartViewDelegate?
    
    /// text that is displayed when the chart is empty
    public var noDataText = "No chart data available."
    
    /// color of the no data text
    public var noDataTextColor: NSUIColor = NSUIColor.blackColor()
    
    /// text that is displayed when the chart is empty that describes why the chart is empty
    public var noDataTextDescription: String?
    
    internal var _legendRenderer: LegendRenderer!
    
    /// object responsible for rendering the data
    public var renderer: DataRenderer?
    
    public var highlighter: IHighlighter?
    
    /// object that manages the bounds and drawing constraints of the chart
    internal var _viewPortHandler: ViewPortHandler!
    
    /// object responsible for animations
    internal var _animator: Animator!
    
    /// flag that indicates if offsets calculation has already been done or not
    private var _offsetsCalculated = false
    
    /// array of Highlight objects that reference the highlighted slices in the chart
    internal var _indicesToHighlight = [Highlight]()
    
    /// `true` if drawing the marker is enabled when tapping on values
    /// (use the `marker` property to specify a marker)
    public var drawMarkers = true
    
    /// - returns: `true` if drawing the marker is enabled when tapping on values
    /// (use the `marker` property to specify a marker)
    public var isDrawMarkersEnabled: Bool { return drawMarkers }
    
    /// The marker that is displayed when a value is clicked on the chart
    public var marker: IMarker?
    
    private var _interceptTouchEvents = false
    
    /// An extra offset to be appended to the viewport's top
    public var extraTopOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's right
    public var extraRightOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's bottom
    public var extraBottomOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's left
    public var extraLeftOffset: CGFloat = 0.0
    
    public func setExtraOffsets(left left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        extraLeftOffset = left
        extraTopOffset = top
        extraRightOffset = right
        extraBottomOffset = bottom
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)

		#if os(iOS)
			self.backgroundColor = NSUIColor.clearColor()
		#endif
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit
    {
        self.removeObserver(self, forKeyPath: "bounds")
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    internal func initialize()
    {
        _animator = Animator()
        _animator.delegate = self

        _viewPortHandler = ViewPortHandler()
        _viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
        
        _legend = Legend()
        _legendRenderer = LegendRenderer(viewPortHandler: _viewPortHandler, legend: _legend)
        
        _xAxis = XAxis()
        
        self.addObserver(self, forKeyPath: "bounds", options: .New, context: nil)
        self.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
    }
    
    // MARK: - ChartViewBase
    
    /// The data for the chart
    public var data: ChartData?
    {
        get
        {
            return _data
        }
        set
        {
            _data = newValue
            _offsetsCalculated = false
            
            if _data == nil
            {
                return
            }
            
            // calculate how many digits are needed
            setupDefaultFormatter(min: _data!.getYMin(), max: _data!.getYMax())
            
            for set in _data!.dataSets
            {
                if set.needsFormatter || set.valueFormatter === _defaultValueFormatter
                {
                    set.valueFormatter = _defaultValueFormatter
                }
            }
            
            // let the chart know there is new data
            notifyDataSetChanged()
        }
    }
    
    /// Clears the chart from all data (sets it to null) and refreshes it (by calling setNeedsDisplay()).
    public func clear()
    {
        _data = nil
        _offsetsCalculated = false
        _indicesToHighlight.removeAll()
        setNeedsDisplay()
    }
    
    /// Removes all DataSets (and thereby Entries) from the chart. Does not set the data object to nil. Also refreshes the chart by calling setNeedsDisplay().
    public func clearValues()
    {
        _data?.clearValues()
        setNeedsDisplay()
    }

    /// - returns: `true` if the chart is empty (meaning it's data object is either null or contains no entries).
    public func isEmpty() -> Bool
    {
        guard let data = _data else { return true }

        if data.entryCount <= 0
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    /// Lets the chart know its underlying data has changed and should perform all necessary recalculations.
    /// It is crucial that this method is called everytime data is changed dynamically. Not calling this method can lead to crashes or unexpected behaviour.
    public func notifyDataSetChanged()
    {
        fatalError("notifyDataSetChanged() cannot be called on ChartViewBase")
    }
    
    /// Calculates the offsets of the chart to the border depending on the position of an eventual legend or depending on the length of the y-axis and x-axis labels and their position
    internal func calculateOffsets()
    {
        fatalError("calculateOffsets() cannot be called on ChartViewBase")
    }
    
    /// calcualtes the y-min and y-max value and the y-delta and x-delta value
    internal func calcMinMax()
    {
        fatalError("calcMinMax() cannot be called on ChartViewBase")
    }
    
    /// calculates the required number of digits for the values that might be drawn in the chart (if enabled), and creates the default value formatter
    internal func setupDefaultFormatter(min min: Double, max: Double)
    {
        // check if a custom formatter is set or not
        var reference = Double(0.0)
        
        if let data = _data where data.entryCount >= 2
        {
            reference = fabs(max - min)
        }
        else
        {
            let absMin = fabs(min)
            let absMax = fabs(max)
            reference = absMin > absMax ? absMin : absMax
        }
        
    
        if _defaultValueFormatter is DefaultValueFormatter
        {
            // setup the formatter with a new number of digits
            let digits = ChartUtils.decimals(reference)
            
            (_defaultValueFormatter as? DefaultValueFormatter)?.decimals
             = digits
        }
    }
    
    public override func drawRect(rect: CGRect)
    {
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        let frame = self.bounds

        if _data === nil
        {
            CGContextSaveGState(context)
            defer { CGContextRestoreGState(context) }
            
            let hasText = noDataText.characters.count > 0
            let hasDescription = noDataTextDescription?.characters.count > 0
            var textHeight = hasText ? infoFont.lineHeight : 0.0
            if hasDescription
            {
                textHeight += infoFont.lineHeight
            }
            
            // if no data, inform the user
            
            var y = (frame.height - textHeight) / 2.0
            
            CGContextSetStrokeColorWithColor(context, noDataTextColor.CGColor)
            
            if hasText
            {
                ChartUtils.drawText(
                    context: context,
                    text: noDataText,
                    point: CGPoint(x: frame.width / 2.0, y: y),
                    align: .Center,
                    attributes: [NSFontAttributeName: infoFont, NSForegroundColorAttributeName: infoTextColor]
                )
                y = y + infoFont.lineHeight
            }
            
            if (noDataTextDescription != nil && (noDataTextDescription!).characters.count > 0)
            {
                ChartUtils.drawText(context: context, text: noDataTextDescription!, point: CGPoint(x: frame.width / 2.0, y: y), align: .Center, attributes: [NSFontAttributeName: infoFont, NSForegroundColorAttributeName: infoTextColor])
            }
            
            return
        }
        
        if (!_offsetsCalculated)
        {
            calculateOffsets()
            _offsetsCalculated = true
        }
    }
    
    /// draws the description text in the bottom right corner of the chart
    internal func drawDescription(context context: CGContext)
    {
        if (descriptionText.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) == 0)
        {
            return
        }
        
        let frame = self.bounds
        
        var attrs = [String : AnyObject]()
        
        var font = descriptionFont
        
        if (font == nil)
        {
            #if os(tvOS)
                // 23 is the smallest recommended font size on the TV
                font = NSUIFont.systemFontOfSize(23, weight: UIFontWeightMedium)
            #else
                font = NSUIFont.systemFontOfSize(NSUIFont.systemFontSize())
            #endif
        }
        
        attrs[NSFontAttributeName] = font
        attrs[NSForegroundColorAttributeName] = descriptionTextColor

        if descriptionTextPosition == nil
        {
            ChartUtils.drawText(
                context: context,
                text: descriptionText,
                point: CGPoint(
                    x: frame.width - _viewPortHandler.offsetRight - 10.0,
                    y: frame.height - _viewPortHandler.offsetBottom - 10.0 - (font?.lineHeight ?? 0.0)),
                align: descriptionTextAlign,
                attributes: attrs)
        }
        else
        {
            ChartUtils.drawText(
                context: context,
                text: descriptionText,
                point: descriptionTextPosition!,
                align: descriptionTextAlign,
                attributes: attrs)
        }
    }
    
    // MARK: - Highlighting
    
    /// - returns: The array of currently highlighted values. This might an empty if nothing is highlighted.
    public var highlighted: [Highlight]
    {
        return _indicesToHighlight
    }
    
    /// Set this to false to prevent values from being highlighted by tap gesture.
    /// Values can still be highlighted via drag or programmatically.
    /// **default**: true
    public var highlightPerTapEnabled: Bool
    {
        get { return _highlightPerTapEnabled }
        set { _highlightPerTapEnabled = newValue }
    }
    
    /// - returns: `true` if values can be highlighted via tap gesture, `false` ifnot.
    public var isHighLightPerTapEnabled: Bool
    {
        return highlightPerTapEnabled
    }
    
    /// Checks if the highlight array is null, has a length of zero or if the first object is null.
    /// - returns: `true` if there are values to highlight, `false` ifthere are no values to highlight.
    public func valuesToHighlight() -> Bool
    {
        return _indicesToHighlight.count > 0
    }

    /// Highlights the values at the given indices in the given DataSets. Provide
    /// null or an empty array to undo all highlighting. 
    /// This should be used to programmatically highlight values. 
    /// This DOES NOT generate a callback to the delegate.
    public func highlightValues(highs: [Highlight]?)
    {
        // set the indices to highlight
        _indicesToHighlight = highs ?? [Highlight]()
        
        if (_indicesToHighlight.isEmpty)
        {
            self.lastHighlighted = nil
        }
        else
        {
            self.lastHighlighted = _indicesToHighlight[0];
        }

        // redraw the chart
        setNeedsDisplay()
    }
    
    
    /// Highlights the values represented by the provided Highlight object
    /// This DOES NOT generate a callback to the delegate.
    /// - parameter highlight: contains information about which entry should be highlighted
    public func highlightValue(highlight: Highlight?)
    {
        highlightValue(highlight: highlight, callDelegate: false)
    }
    
    /// Highlights the value at the given x-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    public func highlightValue(x x: Double, dataSetIndex: Int)
    {
        highlightValue(x: x, dataSetIndex: dataSetIndex, callDelegate: true)
    }
    
    /// Highlights the value at the given x-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    public func highlightValue(x x: Double, dataSetIndex: Int, callDelegate: Bool)
    {
        guard let data = _data else
        {
            Swift.print("Value not highlighted because data is nil")
            return
        }

        if dataSetIndex < 0 || dataSetIndex >= data.dataSetCount
        {
            highlightValue(highlight: nil, callDelegate: callDelegate)
        }
        else
        {
            highlightValue(highlight: Highlight(x: x, dataSetIndex: dataSetIndex), callDelegate: callDelegate)
        }
    }

    /// Highlights the value selected by touch gesture.
    public func highlightValue(highlight highlight: Highlight?, callDelegate: Bool)
    {
        var entry: ChartDataEntry?
        var h = highlight
        
        if (h == nil)
        {
            _indicesToHighlight.removeAll(keepCapacity: false)
        }
        else
        {
            // set the indices to highlight
            entry = _data?.entryForHighlight(h!)
            if (entry == nil)
            {
                h = nil
                _indicesToHighlight.removeAll(keepCapacity: false)
            }
            else
            {
                _indicesToHighlight = [h!]
            }
        }
        
        if (callDelegate && delegate != nil)
        {
            if (h == nil)
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
    
    /// - returns: The Highlight object (contains x-index and DataSet index) of the
    /// selected value at the given touch point inside the Line-, Scatter-, or
    /// CandleStick-Chart.
    public func getHighlightByTouchPoint(pt: CGPoint) -> Highlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.x, y: pt.y)
    }

    /// The last value that was highlighted via touch.
    public var lastHighlighted: Highlight?
  
    // MARK: - Markers

    /// draws all MarkerViews on the highlighted positions
    internal func drawMarkers(context context: CGContext)
    {
        // if there is no marker view or drawing marker is disabled
        guard
            let marker = marker
            where isDrawMarkersEnabled &&
                valuesToHighlight()
            else { return }
        
        for i in 0 ..< _indicesToHighlight.count
        {
            let highlight = _indicesToHighlight[i]
            
            guard let
                set = data?.getDataSetByIndex(highlight.dataSetIndex),
                e = _data?.entryForHighlight(highlight)
                else { continue }
            
            let entryIndex = set.entryIndex(entry: e)
            if entryIndex > Int(Double(set.entryCount) * _animator.phaseX)
            {
                continue
            }

            let pos = getMarkerPosition(highlight: highlight)

            // check bounds
            if !_viewPortHandler.isInBounds(x: pos.x, y: pos.y)
            {
                continue
            }

            // callbacks to update the content
            marker.refreshContent(entry: e, highlight: highlight)
            
            // draw the marker
            marker.draw(context: context, point: pos)
        }
    }
    
    /// - returns: The actual position in pixels of the MarkerView for the given Entry in the given DataSet.
    public func getMarkerPosition(highlight highlight: Highlight) -> CGPoint
    {
        return CGPoint(x: highlight.drawX, y: highlight.drawY)
    }
    
    // MARK: - Animation
    
    /// - returns: The animator responsible for animating chart values.
    public var chartAnimator: Animator!
    {
        return _animator
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingX: an easing function for the animation on the x axis
    /// - parameter easingY: an easing function for the animation on the y axis
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easingX: ChartEasingFunctionBlock?, easingY: ChartEasingFunctionBlock?)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingX: easingX, easingY: easingY)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOptionX: the easing function for the animation on the x axis
    /// - parameter easingOptionY: the easing function for the animation on the y axis
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOptionX: easingOptionX, easingOptionY: easingOptionY)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easing: ChartEasingFunctionBlock?)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easing: an easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, easing: ChartEasingFunctionBlock?)
    {
        _animator.animate(xAxisDuration: xAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(xAxisDuration: xAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval)
    {
        _animator.animate(xAxisDuration: xAxisDuration)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    public func animate(yAxisDuration yAxisDuration: NSTimeInterval, easing: ChartEasingFunctionBlock?)
    {
        _animator.animate(yAxisDuration: yAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingOption: the easing function for the animation
    public func animate(yAxisDuration yAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    public func animate(yAxisDuration yAxisDuration: NSTimeInterval)
    {
        _animator.animate(yAxisDuration: yAxisDuration)
    }
    
    // MARK: - Accessors

    /// - returns: The current y-max value across all DataSets
    public var chartYMax: Double
    {
        return _data?.yMax ?? 0.0
    }

    /// - returns: The current y-min value across all DataSets
    public var chartYMin: Double
    {
        return _data?.yMin ?? 0.0
    }
    
    public var chartXMax: Double
    {
        return _xAxis._axisMaximum
    }
    
    public var chartXMin: Double
    {
        return _xAxis._axisMinimum
    }
    
    public var xRange: Double
    {
        return _xAxis.axisRange
    }
    
    /// *
    /// - note: (Equivalent of getCenter() in MPAndroidChart, as center is already a standard in iOS that returns the center point relative to superview, and MPAndroidChart returns relative to self)*
    /// - returns: The center point of the chart (the whole View) in pixels.
    public var midPoint: CGPoint
    {
        let bounds = self.bounds
        return CGPoint(x: bounds.origin.x + bounds.size.width / 2.0, y: bounds.origin.y + bounds.size.height / 2.0)
    }
    
    public func setDescriptionTextPosition(x x: CGFloat, y: CGFloat)
    {
        descriptionTextPosition = CGPoint(x: x, y: y)
    }
    
    /// - returns: The center of the chart taking offsets under consideration. (returns the center of the content rectangle)
    public var centerOffsets: CGPoint
    {
        return _viewPortHandler.contentCenter
    }
    
    /// - returns: The Legend object of the chart. This method can be used to get an instance of the legend in order to customize the automatically generated Legend.
    public var legend: Legend
    {
        return _legend
    }
    
    /// - returns: The renderer object responsible for rendering / drawing the Legend.
    public var legendRenderer: LegendRenderer!
    {
        return _legendRenderer
    }
    
    /// - returns: The rectangle that defines the borders of the chart-value surface (into which the actual values are drawn).
    public var contentRect: CGRect
    {
        return _viewPortHandler.contentRect
    }
    
    /// Get all Entry objects at the given index across all DataSets.
    public func getEntriesAtIndex(xValue: Double) -> [ChartDataEntry]
    {
        var vals = [ChartDataEntry]()
        
        guard let data = _data else { return vals }

        for i in 0 ..< data.dataSetCount
        {
            let set = data.getDataSetByIndex(i)
            let e = set.entryForXValue(xValue)
            if (e !== nil)
            {
                vals.append(e!)
            }
        }
        
        return vals
    }
    
    /// - returns: The ViewPortHandler of the chart that is responsible for the
    /// content area of the chart and its offsets and dimensions.
    public var viewPortHandler: ViewPortHandler!
    {
        return _viewPortHandler
    }
    
    /// - returns: The bitmap that represents the chart.
    public func getChartImage(transparent transparent: Bool) -> NSUIImage?
    {
        NSUIGraphicsBeginImageContextWithOptions(bounds.size, opaque || !transparent, NSUIMainScreen()?.nsuiScale ?? 1.0)
        
        let context = NSUIGraphicsGetCurrentContext()
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: bounds.size)
        
        if (opaque || !transparent)
        {
            // Background color may be partially transparent, we must fill with white if we want to output an opaque image
            CGContextSetFillColorWithColor(context, NSUIColor.whiteColor().CGColor)
            CGContextFillRect(context, rect)
            
            if (self.backgroundColor !== nil)
            {
                CGContextSetFillColorWithColor(context, self.backgroundColor?.CGColor)
                CGContextFillRect(context, rect)
            }
        }
        
        if let context = context
        {
            nsuiLayer?.renderInContext(context)
        }
        
        let image = NSUIGraphicsGetImageFromCurrentImageContext()
        
        NSUIGraphicsEndImageContext()
        
        return image
    }
    
    public enum ImageFormat
    {
        case JPEG
        case PNG
    }
    
    /// Saves the current chart state with the given name to the given path on
    /// the sdcard leaving the path empty "" will put the saved file directly on
    /// the SD card chart is saved as a PNG image, example:
    /// saveToPath("myfilename", "foldername1/foldername2")
    ///
    /// - parameter filePath: path to the image to save
    /// - parameter format: the format to save
    /// - parameter compressionQuality: compression quality for lossless formats (JPEG)
    ///
    /// - returns: `true` if the image was saved successfully
    public func saveToPath(path: String, format: ImageFormat, compressionQuality: Double) -> Bool
    {
		if let image = getChartImage(transparent: format != .JPEG) {
			var imageData: NSData!
			switch (format)
			{
			case .PNG:
				imageData = NSUIImagePNGRepresentation(image)
				break
				
			case .JPEG:
				imageData = NSUIImageJPEGRepresentation(image, CGFloat(compressionQuality))
				break
			}

			return imageData.writeToFile(path, atomically: true)
		}
		return false
    }
    
    #if !os(tvOS) && !os(OSX)
    /// Saves the current state of the chart to the camera roll
    public func saveToCameraRoll()
    {
		if let img = getChartImage(transparent: false) {
			UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
		}
    }
    #endif
    
    internal var _viewportJobs = [ViewPortJob]()
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if (keyPath == "bounds" || keyPath == "frame")
        {
            let bounds = self.bounds
            
            if (_viewPortHandler !== nil &&
                (bounds.size.width != _viewPortHandler.chartWidth ||
                bounds.size.height != _viewPortHandler.chartHeight))
            {
                _viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
                
                // Finish any pending viewport changes
                while (!_viewportJobs.isEmpty)
                {
                    let job = _viewportJobs.removeAtIndex(0)
                    job.doJob()
                }
                
                notifyDataSetChanged()
            }
        }
    }
    
    public func removeViewportJob(job: ViewPortJob)
    {
        if let index = _viewportJobs.indexOf({ $0 === job })
        {
            _viewportJobs.removeAtIndex(index)
        }
    }
    
    public func clearAllViewportJobs()
    {
        _viewportJobs.removeAll(keepCapacity: false)
    }
    
    public func addViewportJob(job: ViewPortJob)
    {
        if (_viewPortHandler.hasChartDimens)
        {
            job.doJob()
        }
        else
        {
            _viewportJobs.append(job)
        }
    }
    
    /// **default**: true
    /// - returns: `true` if chart continues to scroll after touch up, `false` ifnot.
    public var isDragDecelerationEnabled: Bool
        {
            return dragDecelerationEnabled
    }
    
    /// Deceleration friction coefficient in [0 ; 1] interval, higher values indicate that speed will decrease slowly, for example if it set to 0, it will stop immediately.
    /// 1 is an invalid value, and will be converted to 0.999 automatically.
    /// 
    /// **default**: true
    public var dragDecelerationFrictionCoef: CGFloat
    {
        get
        {
            return _dragDecelerationFrictionCoef
        }
        set
        {
            var val = newValue
            if (val < 0.0)
            {
                val = 0.0
            }
            if (val >= 1.0)
            {
                val = 0.999
            }
            
            _dragDecelerationFrictionCoef = val
        }
    }
    
    /// The maximum distance in screen pixels away from an entry causing it to highlight.
    /// **default**: 500.0
    public var maxHighlightDistance: CGFloat = 500.0
    
    /// the number of maximum visible drawn values on the chart only active when `drawValuesEnabled` is enabled
    public var maxVisibleCount: Int
    {
        return Int(INT_MAX)
    }
    
    // MARK: - AnimatorDelegate
    
    public func animatorUpdated(chartAnimator: Animator)
    {
        setNeedsDisplay()
    }
    
    public func animatorStopped(chartAnimator: Animator)
    {
        
    }
    
    // MARK: - Touches
    
    public override func nsuiTouchesBegan(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        if (!_interceptTouchEvents)
        {
            super.nsuiTouchesBegan(touches, withEvent: event)
        }
    }
    
    public override func nsuiTouchesMoved(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        if (!_interceptTouchEvents)
        {
            super.nsuiTouchesMoved(touches, withEvent: event)
        }
    }
    
    public override func nsuiTouchesEnded(touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        if (!_interceptTouchEvents)
        {
            super.nsuiTouchesEnded(touches, withEvent: event)
        }
    }
    
    public override func nsuiTouchesCancelled(touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
    {
        if (!_interceptTouchEvents)
        {
            super.nsuiTouchesCancelled(touches, withEvent: event)
        }
    }
}
