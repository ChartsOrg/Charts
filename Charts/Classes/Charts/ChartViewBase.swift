//
//  ChartViewBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//
//  Based on https://github.com/PhilJay/MPAndroidChart/commit/c42b880

import Foundation
import UIKit;

@objc
public protocol ChartViewDelegate
{
    /// Called when a value has been selected inside the chart.
    /// :entry: The selected Entry.
    /// :dataSetIndex: The index in the datasets array of the data object the Entrys DataSet is in.
    optional func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight);
    
    // Called when nothing has been selected or an "un-select" has been made.
    optional func chartValueNothingSelected(chartView: ChartViewBase);
}

public class ChartViewBase: UIView, ChartAnimatorDelegate
{
    // MARK: - Properties
    
    /// custom formatter that is used instead of the auto-formatter if set
    internal var _valueFormatter = NSNumberFormatter()
    
    /// the default value formatter
    internal var _defaultValueFormatter = NSNumberFormatter()
    
    /// object that holds all data that was originally set for the chart, before it was modified or any filtering algorithms had been applied
    internal var _data: ChartData!
    
    /// font object used for drawing the description text in the bottom right corner of the chart
    public var descriptionFont: UIFont? = UIFont(name: "HelveticaNeue", size: 9.0)
    internal var _descriptionTextColor: UIColor! = UIColor.blackColor()
    
    /// font object for drawing the information text when there are no values in the chart
    internal var _infoFont: UIFont! = UIFont(name: "HelveticaNeue", size: 12.0)
    internal var _infoTextColor: UIColor! = UIColor(red: 247.0/255.0, green: 189.0/255.0, blue: 51.0/255.0, alpha: 1.0) // orange
    
    /// description text that appears in the bottom right corner of the chart
    public var descriptionText = "Description"
    
    /// flag that indicates if the chart has been fed with data yet
    internal var _dataNotSet = true
    
    /// if true, units are drawn next to the values in the chart
    internal var _drawUnitInChart = false
    
    /// the number of x-values the chart displays
    internal var _deltaX = CGFloat(1.0)
    
    internal var _chartXMin = Float(0.0)
    internal var _chartXMax = Float(0.0)
    
    /// if true, value highlightning is enabled
    public var highlightEnabled = true
    
    /// the legend object containing all data associated with the legend
    internal var _legend: ChartLegend!;
    
    /// delegate to receive chart events
    public weak var delegate: ChartViewDelegate?
    
    /// text that is displayed when the chart is empty
    public var noDataText = "No chart data available."
    
    /// text that is displayed when the chart is empty that describes why the chart is empty
    public var noDataTextDescription: String?
    
    internal var _legendRenderer: ChartLegendRenderer!
    
    /// object responsible for rendering the data
    public var renderer: ChartDataRendererBase?
    
    /// object that manages the bounds and drawing constraints of the chart
    internal var _viewPortHandler: ChartViewPortHandler!
    
    /// object responsible for animations
    internal var _animator: ChartAnimator!
    
    /// flag that indicates if offsets calculation has already been done or not
    private var _offsetsCalculated = false
    
    /// array of Highlight objects that reference the highlighted slices in the chart
    internal var _indicesToHightlight = [ChartHighlight]()
    
    /// if set to true, the marker is drawn when a value is clicked
    public var drawMarkers = true
    
    /// the view that represents the marker
    public var marker: ChartMarker?
    
    private var _interceptTouchEvents = false
    
    // MARK: - Initializers
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame);
        initialize();
    }
    
    public required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
        initialize();
    }
    
    internal func initialize()
    {
        _animator = ChartAnimator();
        _animator.delegate = self;

        _viewPortHandler = ChartViewPortHandler();
        _viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height);
        
        _legend = ChartLegend();
        _legendRenderer = ChartLegendRenderer(viewPortHandler: _viewPortHandler, legend: _legend);
        
        _defaultValueFormatter.maximumFractionDigits = 1;
        _defaultValueFormatter.minimumFractionDigits = 1;
        _defaultValueFormatter.usesGroupingSeparator = true;
        
        _valueFormatter = _defaultValueFormatter.copy() as NSNumberFormatter;
    }
    
    // MARK: - ChartViewBase
    
    /// The data for the chart
    public var data: ChartData?
    {
        get
        {
            return _data;
        }
        set
        {
            if (newValue == nil)
            {
                println("Charts: data argument is nil on setData()");
                return;
            }
            
            _dataNotSet = false;
            _offsetsCalculated = false;
            _data = newValue;
            
            // calculate how many digits are needed
            calculateFormatter(min: _data.getYMin(), max: _data.getYMax());
            
            notifyDataSetChanged();
        }
    }
    
    /// Clears the chart from all data (sets it to null) and refreshes it (by calling setNeedsDisplay()).
    public func clear()
    {
        _data = nil;
        _dataNotSet = true;
        setNeedsDisplay();
    }
    
    /// Removes all DataSets (and thereby Entries) from the chart. Does not remove the x-values. Also refreshes the chart by calling setNeedsDisplay().
    public func clearValues()
    {
        if (_data !== nil)
        {
            _data.clearValues();
        }
        setNeedsDisplay();
    }
    
    /// Returns true if the chart is empty (meaning it's data object is either null or contains no entries).
    public func isEmpty() -> Bool
    {
        if (_data == nil)
        {
            return true;
        }
        else
        {
            
            if (_data.yValCount <= 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
    
    /// Lets the chart know its underlying data has changed and should perform all necessary recalculations.
    public func notifyDataSetChanged()
    {
        fatalError("notifyDataSetChanged() cannot be called on ChartViewBase");
    }
    
    /// calculates the offsets of the chart to the border depending on the position of an eventual legend or depending on the length of the y-axis and x-axis labels and their position
    internal func calculateOffsets()
    {
        fatalError("calculateOffsets() cannot be called on ChartViewBase");
    }
    
    /// calcualtes the y-min and y-max value and the y-delta and x-delta value
    internal func calcMinMax()
    {
        fatalError("calcMinMax() cannot be called on ChartViewBase");
    }
    
    /// calculates the required number of digits for the values that might be drawn in the chart (if enabled), and creates the default value formatter
    internal func calculateFormatter(#min: Float, max: Float)
    {
        // check if a custom formatter is set or not
        var reference = Float(0.0);
        
        if (_data == nil || _data.xValCount < 2)
        {
            var absMin = fabs(min);
            var absMax = fabs(max);
            reference = absMin > absMax ? absMin : absMax;
        }
        else
        {
            reference = fabs(max - min);
        }
        
        var digits = ChartUtils.decimals(reference);
    
        _defaultValueFormatter.maximumFractionDigits = digits;
        _defaultValueFormatter.minimumFractionDigits = digits;
    }
    
    public override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext();
        let frame = self.bounds;
        
        if (_dataNotSet)
        { // check if there is data
            
            CGContextSaveGState(context);
            
            // if no data, inform the user
            
            ChartUtils.drawText(context: context, text: noDataText, point: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0), align: .Center, attributes: [NSFontAttributeName: _infoFont, NSForegroundColorAttributeName: _infoTextColor]);
            
            if (noDataTextDescription!.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) > 0)
            {   
                var textOffset = -_infoFont.lineHeight / 2.0;
                
                ChartUtils.drawText(context: context, text: noDataTextDescription!, point: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0 + textOffset), align: .Center, attributes: [NSFontAttributeName: _infoFont, NSForegroundColorAttributeName: _infoTextColor]);
            }
            
            return;
        }
        
        if (!_offsetsCalculated)
        {
            calculateOffsets();
            _offsetsCalculated = true;
        }
    }
    
    /// draws the description text in the bottom right corner of the chart
    internal func drawDescription(#context: CGContext)
    {
        if (descriptionText.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) == 0)
        {
            return;
        }
        
        let frame = self.bounds;
        
        var attrs = [NSObject: AnyObject]();
        
        var font = descriptionFont;
        
        if (font == nil)
        {
            font = UIFont.systemFontOfSize(UIFont.systemFontSize());
        }
        
        attrs[NSFontAttributeName] = font;
        attrs[NSForegroundColorAttributeName] = UIColor.blackColor();
        
        ChartUtils.drawText(context: context, text: descriptionText, point: CGPoint(x: frame.width - _viewPortHandler.offsetRight - 10.0, y: frame.height - _viewPortHandler.offsetBottom - 10.0 - font!.lineHeight), align: .Right, attributes: attrs);
    }
    
    /// disables intercept touchevents
    public func disableScroll()
    {
        _interceptTouchEvents = true;
    }
    
    /// enables intercept touchevents
    public func enableScroll()
    {
        _interceptTouchEvents = false;
    }
    
    // MARK: - Highlighting
    
    /// Returns the array of currently highlighted values. This might be null or empty if nothing is highlighted.
    public var highlighted: [ChartHighlight]
    {
        return _indicesToHightlight;
    }
    
    /// Returns true if there are values to highlight,
    /// false if there are no values to highlight.
    /// Checks if the highlight array is null, has a length of zero or if the first object is null.
    public func valuesToHighlight() -> Bool
    {
        return _indicesToHightlight.count > 0;
    }

    /// Highlights the values at the given indices in the given DataSets. Provide
    /// null or an empty array to undo all highlighting. 
    /// This should be used to programmatically highlight values. 
    /// This DOES NOT generate a callback to the delegate.
    public func highlightValues(highs: [ChartHighlight]?)
    {
        // set the indices to highlight
        _indicesToHightlight = highs ?? [ChartHighlight]();

        // redraw the chart
        setNeedsDisplay();
    }
    
    /// Highlights the value at the given x-index in the given DataSet. 
    /// Provide -1 as the x-index to undo all highlighting.
    public func highlightValue(#xIndex: Int, dataSetIndex: Int, callDelegate: Bool)
    {
        if (xIndex < 0 || dataSetIndex < 0 || xIndex >= _data.xValCount || dataSetIndex >= _data.dataSetCount)
        {
            highlightValue(highlight: nil, callDelegate: callDelegate);
        }
        else
        {
            highlightValue(highlight: ChartHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex), callDelegate: callDelegate);
        }
    }

    /// Highlights the value selected by touch gesture.
    public func highlightValue(#highlight: ChartHighlight?, callDelegate: Bool)
    {
        if (highlight == nil)
        {
            _indicesToHightlight.removeAll(keepCapacity: false);
        }
        else
        {
            // set the indices to highlight
            _indicesToHightlight = [highlight!];
        }

        // redraw the chart
        setNeedsDisplay();
        
        if (callDelegate && delegate != nil)
        {
            if (highlight == nil)
            {
                delegate!.chartValueNothingSelected!(self);
            }
            else
            {
                var e = _data.getEntryForHighlight(highlight!);

                // notify the listener
                delegate!.chartValueSelected!(self, entry: e, dataSetIndex: highlight!.dataSetIndex, highlight: highlight!);
            }
        }
    }
  
    // MARK: - Markers

    /// draws all MarkerViews on the highlighted positions
    internal func drawMarkers(#context: CGContext)
    {
        // if there is no marker view or drawing marker is disabled
        if (marker === nil || !drawMarkers || !valuesToHighlight())
        {
            return;
        }

        for (var i = 0, count = _indicesToHightlight.count; i < count; i++)
        {
            let highlight = _indicesToHightlight[i];
            let xIndex = highlight.xIndex;
            let dataSetIndex = highlight.dataSetIndex;

            if (xIndex <= Int(_deltaX) && xIndex <= Int(_deltaX * _animator.phaseX))
            {
                let e = _data.getEntryForHighlight(highlight);

                var pos = getMarkerPosition(entry: e, dataSetIndex: dataSetIndex);

                // check bounds
                if (!_viewPortHandler.isInBounds(x: pos.x, y: pos.y))
                {
                    continue;
                }

                // callbacks to update the content
                marker!.refreshContent(entry: e, dataSetIndex: dataSetIndex);

                let markerSize = marker!.size;
                if (pos.y - markerSize.height <= 0.0)
                {
                    let y = markerSize.height - pos.y;
                    marker!.draw(context: context, point: CGPoint(x: pos.x, y: pos.y + y));
                }
                else
                {
                    marker!.draw(context: context, point: pos);
                }
            }
        }
    }
    
    /// Returns the actual position in pixels of the MarkerView for the given Entry in the given DataSet.
    public func getMarkerPosition(#entry: ChartDataEntry, dataSetIndex: Int) -> CGPoint
    {
        fatalError("getMarkerPosition() cannot be called on ChartViewBase");
    }
    
    // MARK: - Animation
    
    /// Returns the animator responsible for animating chart values.
    public var animator: ChartAnimator!
    {
        return _animator;
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: yAxisDuration duration for animating the y axis
    /// :param: easing an easing function for the animation
    public func animate(#xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easing: ((elapsed: NSTimeInterval, duration: NSTimeInterval) -> CGFloat)?)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easing: easing);
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: yAxisDuration duration for animating the y axis
    /// :param: easingOption the easing function for the animation
    public func animate(#xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOption: easingOption);
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: yAxisDuration duration for animating the y axis
    public func animate(#xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration);
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: easing an easing function for the animation
    public func animate(#xAxisDuration: NSTimeInterval, easing: ((elapsed: NSTimeInterval, duration: NSTimeInterval) -> CGFloat)?)
    {
        _animator.animate(xAxisDuration: xAxisDuration, easing: easing);
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    /// :param: easingOption the easing function for the animation
    public func animate(#xAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(xAxisDuration: xAxisDuration, easingOption: easingOption);
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: xAxisDuration duration for animating the x axis
    public func animate(#xAxisDuration: NSTimeInterval)
    {
        _animator.animate(xAxisDuration: xAxisDuration);
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: yAxisDuration duration for animating the y axis
    /// :param: easing an easing function for the animation
    public func animate(#yAxisDuration: NSTimeInterval, easing: ((elapsed: NSTimeInterval, duration: NSTimeInterval) -> CGFloat)?)
    {
        _animator.animate(yAxisDuration: yAxisDuration, easing: easing);
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: yAxisDuration duration for animating the y axis
    /// :param: easingOption the easing function for the animation
    public func animate(#yAxisDuration: NSTimeInterval, easingOption: ChartEasingOption)
    {
        _animator.animate(yAxisDuration: yAxisDuration, easingOption: easingOption);
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If animate(...) is called, no further calling of invalidate() is necessary to refresh the chart.
    /// :param: yAxisDuration duration for animating the y axis
    public func animate(#yAxisDuration: NSTimeInterval)
    {
        _animator.animate(yAxisDuration: yAxisDuration);
    }
    
    // MARK: - Accessors

    /// returns the total value (sum) of all y-values across all DataSets
    public var yValueSum: Float
    {
        return _data.yValueSum;
    }

    /// returns the current y-max value across all DataSets
    public var chartYMax: Float
    {
        return _data.yMax;
    }

    /// returns the current y-min value across all DataSets
    public var chartYMin: Float
    {
        return _data.yMin;
    }
    
    public var chartXMax: Float
    {
        return _chartXMax;
    }
    
    public var chartXMin: Float
    {
        return _chartXMin;
    }
    
    /// returns the average value of all values the chart holds
    public func getAverage() -> Float
    {
        return yValueSum / Float(_data.yValCount);
    }
    
    /// returns the average value for a specific DataSet (with a specific label) in the chart
    public func getAverage(#dataSetLabel: String) -> Float
    {
        var ds = _data.getDataSetByLabel(dataSetLabel, ignorecase: true);
        if (ds == nil)
        {
            return 0.0;
        }
        
        return ds!.yValueSum / Float(ds!.entryCount);
    }
    
    /// returns the total number of values the chart holds (across all DataSets)
    public var getValueCount: Int
    {
        return _data.yValCount;
    }
    
    /// Returns the center of the chart taking offsets under consideration. (returns the center of the content rectangle)
    public var centerOffsets: CGPoint
    {
        return _viewPortHandler.contentCenter;
    }
    
    /// Returns the Legend object of the chart. This method can be used to get an instance of the legend in order to customize the automatically generated Legend.
    public var legend: ChartLegend
    {
        return _legend;
    }
    
    /// Returns the renderer object responsible for rendering / drawing the Legend.
    public var legendRenderer: ChartLegendRenderer!
    {
        return _legendRenderer;
    }
    
    /// Returns the rectangle that defines the borders of the chart-value surface (into which the actual values are drawn).
    public var contentRect: CGRect
    {
        return _viewPortHandler.contentRect;
    }
    
    /// Sets the formatter to be used for drawing the values inside the chart.
    /// If no formatter is set, the chart will automatically determine a reasonable
    /// formatting (concerning decimals) for all the values that are drawn inside
    /// the chart. Set this to nil to re-enable auto formatting.
    public var valueFormatter: NSNumberFormatter!
    {
        get
        {
            return _valueFormatter;
        }
        set
        {
            if (newValue === nil)
            {
                _valueFormatter = _defaultValueFormatter.copy() as NSNumberFormatter;
            }
            else
            {
                _valueFormatter = newValue;
            }
        }
    }
    
    /// returns the x-value at the given index
    public func getXValue(index: Int) -> String!
    {
        if (_data == nil || _data.xValCount <= index)
        {
            return nil;
        }
        else
        {
            return _data.xVals[index];
        }
    }
    
    /// Get all Entry objects at the given index across all DataSets.
    public func getEntriesAtIndex(xIndex: Int) -> [ChartDataEntry]
    {
        var vals = [ChartDataEntry]();
        
        for (var i = 0, count = _data.dataSetCount; i < count; i++)
        {
            var set = _data.getDataSetByIndex(i);
            var e = set!.entryForXIndex(xIndex);
            if (e !== nil)
            {
                vals.append(e);
            }
        }
        
        return vals;
    }
    
    /// returns the percentage the given value has of the total y-value sum
    public func percentOfTotal(val: Float) -> Float
    {
        return val / _data.yValueSum * 100.0;
    }
    
    /// Returns the ViewPortHandler of the chart that is responsible for the
    /// content area of the chart and its offsets and dimensions.
    public var viewPortHandler: ChartViewPortHandler!
    {
        return _viewPortHandler;
    }
    
    /// Returns the bitmap that represents the chart.
    public func getChartImage() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, UIScreen.mainScreen().scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext());
        
        var image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    public enum ImageFormat
    {
        case JPEG;
        case PNG;
    }
    
    /// Saves the current chart state with the given name to the given path on
    /// the sdcard leaving the path empty "" will put the saved file directly on
    /// the SD card chart is saved as a PNG image, example:
    /// saveToPath("myfilename", "foldername1/foldername2");
    ///
    /// :filePath: path to the image to save
    /// :format: the format to save
    /// :compressionQuality: compression quality for lossless formats (JPEG)
    ///
    /// :returns: true if the image was saved successfully
    public func saveToPath(path: String, format: ImageFormat, compressionQuality: Float) -> Bool
    {
        var image = getChartImage();

        var imageData: NSData!;
        switch (format)
        {
        case .PNG:
            imageData = UIImagePNGRepresentation(image);
            break;
            
        case .JPEG:
            imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality));
            break;
        }

        return imageData.writeToFile(path, atomically: true);
    }
    
    /// Saves the current state of the chart to the camera roll
    public func saveToCameraRoll()
    {
        UIImageWriteToSavedPhotosAlbum(getChartImage(), nil, nil, nil);
    }
    
    public override var bounds: CGRect
    {
        get
        {
            return super.bounds;
        }
        set
        {
            super.bounds = newValue;
            
            if (_viewPortHandler !== nil)
            {
                _viewPortHandler.setChartDimens(width: newValue.size.width, height: newValue.size.height);
            }
            
            notifyDataSetChanged();
        }
    }
    
    /// if true, value highlightning is enabled
    public var isHighlightEnabled: Bool { return highlightEnabled; }
    
    // MARK: - ChartAnimatorDelegate
    
    public func chartAnimatorUpdated(chartAnimator: ChartAnimator)
    {
        setNeedsDisplay();
    }
    
    // MARK: - Touches
    
    public override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        if (!_interceptTouchEvents)
        {
            super.touchesBegan(touches, withEvent: event);
        }
    }
    
    public override func touchesMoved(touches: NSSet, withEvent event: UIEvent)
    {
        if (!_interceptTouchEvents)
        {
            super.touchesMoved(touches, withEvent: event);
        }
    }
    
    public override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        if (!_interceptTouchEvents)
        {
            super.touchesEnded(touches, withEvent: event);
        }
    }
    
    public override func touchesCancelled(touches: NSSet, withEvent event: UIEvent)
    {
        if (!_interceptTouchEvents)
        {
            super.touchesCancelled(touches, withEvent: event);
        }
    }
}