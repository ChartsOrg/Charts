//
//  PieRadarChartViewBase.swift
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
import CoreGraphics.CGBase
import UIKit.UIGestureRecognizer

/// Base class of PieChartView and RadarChartView.
public class PieRadarChartViewBase: ChartViewBase
{
    /// holds the normalized version of the current rotation angle of the chart
    private var _rotationAngle = CGFloat(270.0);
    
    /// holds the raw version of the current rotation angle of the chart
    private var _rawRotationAngle = CGFloat(270.0);
    
    /// flag that indicates if rotation is enabled or not
    public var rotationEnabled = true
    
    private var _tapGestureRecognizer: UITapGestureRecognizer!
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame);
    }
    
    public required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
    }
    
    deinit
    {
        stopDeceleration();
    }
    
    internal override func initialize()
    {
        super.initialize();
        
        _tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapGestureRecognized:"));
        self.addGestureRecognizer(_tapGestureRecognizer);
    }
    
    internal override func calcMinMax()
    {
        _deltaX = CGFloat(_data.xVals.count - 1);
    }
    
    public override func notifyDataSetChanged()
    {
        if (_dataNotSet)
        {
            return;
        }
        
        calcMinMax();
        
        _legendRenderer.computeLegend(_data);
        
        calculateOffsets();
        
        setNeedsDisplay();
    }
  
    internal override func calculateOffsets()
    {
        var legendLeft = CGFloat(0.0);
        var legendRight = CGFloat(0.0);
        var legendBottom = CGFloat(0.0);
        var legendTop = CGFloat(0.0);

        if (_legend != nil && _legend.enabled)
        {
            if (_legend.position == .RightOfChartCenter)
            {
                // this is the space between the legend and the chart
                var spacing = CGFloat(13.0);

                legendRight = self.fullLegendWidth + spacing;
            }
            else if (_legend.position == .RightOfChart)
            {

                // this is the space between the legend and the chart
                var spacing = CGFloat(8.0);
                var legendWidth = self.fullLegendWidth + spacing;
                var legendHeight = _legend.neededHeight + _legend.textHeightMax;

                var c = self.center;

                var bottomRight = CGPoint(x: self.bounds.width - legendWidth + 15.0, y: legendHeight + 15);
                var distLegend = distanceToCenter(x: bottomRight.x, y: bottomRight.y);

                var reference = getPosition(center: c, dist: self.radius,
                    angle: angleForPoint(x: bottomRight.x, y: bottomRight.y));

                var distReference = distanceToCenter(x: reference.x, y: reference.y);
                var min = CGFloat(5.0);

                if (distLegend < distReference)
                {
                    var diff = distReference - distLegend;
                    legendRight = min + diff;
                }

                if (bottomRight.y >= c.y && self.bounds.height - legendWidth > self.bounds.width)
                {
                    legendRight = legendWidth;
                }
            }
            else if (_legend.position == .LeftOfChartCenter)
            {
                // this is the space between the legend and the chart
                var spacing = CGFloat(13.0);

                legendLeft = self.fullLegendWidth + spacing;
            }
            else if (_legend.position == .LeftOfChart)
            {

                // this is the space between the legend and the chart
                var spacing = CGFloat(8.0);
                var legendWidth = self.fullLegendWidth + spacing;
                var legendHeight = _legend.neededHeight + _legend.textHeightMax;

                var c = self.center;

                var bottomLeft = CGPoint(x: legendWidth - 15.0, y: legendHeight + 15);
                var distLegend = distanceToCenter(x: bottomLeft.x, y: bottomLeft.y);

                var reference = getPosition(center: c, dist: self.radius,
                    angle: angleForPoint(x: bottomLeft.x, y: bottomLeft.y));

                var distReference = distanceToCenter(x: reference.x, y: reference.y);
                var min = CGFloat(5.0);

                if (distLegend < distReference)
                {
                    var diff = distReference - distLegend;
                    legendLeft = min + diff;
                }

                if (bottomLeft.y >= c.y && self.bounds.height - legendWidth > self.bounds.width)
                {
                    legendLeft = legendWidth;
                }
            }
            else if (_legend.position == .BelowChartLeft
                    || _legend.position == .BelowChartRight
                    || _legend.position == .BelowChartCenter)
            {
                legendBottom = self.requiredBottomOffset;
            }
            
            legendLeft += self.requiredBaseOffset;
            legendRight += self.requiredBaseOffset;
            legendTop += self.requiredBaseOffset;
        }

        var min = CGFloat(10.0);

        var offsetLeft = max(min, legendLeft);
        var offsetTop = max(min, legendTop);
        var offsetRight = max(min, legendRight);
        var offsetBottom = max(min, max(self.requiredBaseOffset, legendBottom));

        _viewPortHandler.restrainViewPort(offsetLeft: offsetLeft, offsetTop: offsetTop, offsetRight: offsetRight, offsetBottom: offsetBottom);
    }

    /// returns the angle relative to the chart center for the given point on the chart in degrees.
    /// The angle is always between 0 and 360°, 0° is NORTH, 90° is EAST, ...
    public func angleForPoint(#x: CGFloat, y: CGFloat) -> CGFloat
    {
        var c = centerOffsets;
        
        var tx = Double(x - c.x);
        var ty = Double(y - c.y);
        var length = sqrt(tx * tx + ty * ty);
        var r = acos(ty / length);

        var angle = r * ChartUtils.Math.RAD2DEG;

        if (x > c.x)
        {
            angle = 360.0 - angle;
        }

        // add 90° because chart starts EAST
        angle = angle + 90.0;

        // neutralize overflow
        if (angle > 360.0)
        {
            angle = angle - 360.0;
        }

        return CGFloat(angle);
    }
    
    /// Calculates the position around a center point, depending on the distance
    /// from the center, and the angle of the position around the center.
    internal func getPosition(#center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint
    {
        var a = cos(angle * ChartUtils.Math.FDEG2RAD);
        return CGPoint(x: center.x + dist * cos(angle * ChartUtils.Math.FDEG2RAD),
                y: center.y + dist * sin(angle * ChartUtils.Math.FDEG2RAD));
    }

    /// Returns the distance of a certain point on the chart to the center of the chart.
    public func distanceToCenter(#x: CGFloat, y: CGFloat) -> CGFloat
    {
        var c = self.centerOffsets;

        var dist = CGFloat(0.0);

        var xDist = CGFloat(0.0);
        var yDist = CGFloat(0.0);

        if (x > c.x)
        {
            xDist = x - c.x;
        }
        else
        {
            xDist = c.x - x;
        }

        if (y > c.y)
        {
            yDist = y - c.y;
        }
        else
        {
            yDist = c.y - y;
        }

        // pythagoras
        dist = sqrt(pow(xDist, 2.0) + pow(yDist, 2.0));

        return dist;
    }

    /// Returns the xIndex for the given angle around the center of the chart.
    /// Returns -1 if not found / outofbounds.
    public func indexForAngle(angle: CGFloat) -> Int
    {
        fatalError("indexForAngle() cannot be called on PieRadarChartViewBase");
    }

    /// current rotation angle of the pie chart
    /// :returns will always return a normalized value, which will be between 0.0 < 360.0
    /// :default: 270f --> top (NORTH)
    public var rotationAngle: CGFloat
    {
        get
        {
            return _rotationAngle;
        }
        set
        {
            _rawRotationAngle = newValue;
            _rotationAngle = ChartUtils.normalizedAngleFromAngle(newValue);
            setNeedsDisplay();
        }
    }
    
    /// gets the raw version of the current rotation angle of the pie chart the returned value could be any value, negative or positive, outside of the 360 degrees. 
    /// this is used when working with rotation direction, mainly by gestures and animations.
    public var rawRotationAngle: CGFloat
    {
        return _rawRotationAngle;
    }

    /// returns the diameter of the pie- or radar-chart
    public var diameter: CGFloat
    {
        var content = _viewPortHandler.contentRect;
        return min(content.width, content.height);
    }

    /// Returns the radius of the chart in pixels.
    public var radius: CGFloat
    {
        fatalError("radius cannot be called on PieRadarChartViewBase");
    }

    /// Returns the required bottom offset for the chart.
    internal var requiredBottomOffset: CGFloat
    {
        fatalError("requiredBottomOffset cannot be called on PieRadarChartViewBase");
    }

    /// Returns the base offset needed for the chart without calculating the
    /// legend size.
    internal var requiredBaseOffset: CGFloat
    {
        fatalError("requiredBaseOffset cannot be called on PieRadarChartViewBase");
    }

    /// Returns the required right offset for the chart.
    private var fullLegendWidth: CGFloat
    {
        return _legend.textWidthMax + _legend.formSize + _legend.formToTextSpace;
    }
    
    public override var chartXMax: Float
    {
        return 0.0;
    }
    
    public override var chartXMin: Float
    {
        return 0.0;
    }
    
    /// Returns an array of SelInfo objects for the given x-index.
    /// The SelInfo objects give information about the value at the selected index and the DataSet it belongs to.
    public func getYValsAtIndex(xIndex: Int) -> [ChartSelInfo]
    {
        var vals = [ChartSelInfo]();
        
        for (var i = 0; i < _data.dataSetCount; i++)
        {
            var dataSet = _data.getDataSetByIndex(i);
            
            // extract all y-values from all DataSets at the given x-index
            var yVal = dataSet!.yValForXIndex(xIndex);
            
            if (!isnan(yVal))
            {
                vals.append(ChartSelInfo(value: yVal, dataSetIndex: i, dataSet: dataSet!));
            }
        }
        
        return vals;
    }
    
    public var isRotationEnabled: Bool { return rotationEnabled; }
    
    // MARK: - Animation
    
    private var _spinAnimator: ChartAnimator!;
    
    /// Applys a spin animation to the Chart.
    public func spin(#duration: NSTimeInterval, fromAngle: CGFloat, toAngle: CGFloat, easing: ChartEasingFunctionBlock?)
    {
        if (_spinAnimator != nil)
        {
            _spinAnimator.stop();
        }
        
        _spinAnimator = ChartAnimator();
        _spinAnimator.updateBlock = {
            self.rotationAngle = (toAngle - fromAngle) * self._spinAnimator.phaseX + fromAngle;
        };
        _spinAnimator.stopBlock = { self._spinAnimator = nil; };
        
        _spinAnimator.animate(xAxisDuration: duration, easing: easing);
    }
    
    public func spin(#duration: NSTimeInterval, fromAngle: CGFloat, toAngle: CGFloat, easingOption: ChartEasingOption)
    {
        spin(duration: duration, fromAngle: fromAngle, toAngle: toAngle, easing: easingFunctionFromOption(easingOption));
    }
    
    public func spin(#duration: NSTimeInterval, fromAngle: CGFloat, toAngle: CGFloat)
    {
        spin(duration: duration, fromAngle: fromAngle, toAngle: toAngle, easing: nil);
    }
    
    public func stopSpinAnimation()
    {
        if (_spinAnimator != nil)
        {
            _spinAnimator.stop();
        }
    }
    
    // MARK: - Gestures
    
    private var _touchStartPoint: CGPoint!
    private var _isRotating = false
    private var _defaultTouchEventsWereEnabled = false
    private var _startAngle = CGFloat(0.0)
    
    private struct AngularVelocitySample
    {
        var time: NSTimeInterval;
        var angle: CGFloat;
    }
    
    private var _velocitySamples = [AngularVelocitySample]();
    
    private var _decelerationLastTime: NSTimeInterval = 0.0
    private var _decelerationDisplayLink: CADisplayLink!
    private var _decelerationAngularVelocity: CGFloat = 0.0
    
    public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesBegan(touches, withEvent: event);
        
        // if rotation by touch is enabled
        if (rotationEnabled)
        {
            var touch = touches.first as! UITouch!;
            
            stopDeceleration();
            
            var touchLocation = touch.locationInView(self);
            
            self.resetVelocity();
            
            if (rotationEnabled)
            {
                self.sampleVelocity(touchLocation: touchLocation);
            }
            
            self.setGestureStartAngle(x: touchLocation.x, y: touchLocation.y);
            
            _touchStartPoint = touchLocation;
        }
    }
    
    public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesMoved(touches, withEvent: event);
        
        if (rotationEnabled)
        {
            var touch = touches.first as! UITouch!;
            
            var touchLocation = touch.locationInView(self);
            
            if (isDragDecelerationEnabled)
            {
                sampleVelocity(touchLocation: touchLocation);
            }
            
            if (!_isRotating && distance(eventX: touchLocation.x, startX: _touchStartPoint.x, eventY: touchLocation.y, startY: _touchStartPoint.y) > CGFloat(8.0))
            {
                _isRotating = true;
                
                _defaultTouchEventsWereEnabled = self.defaultTouchEventsEnabled;
                self.defaultTouchEventsEnabled = false;
            }
            else
            {
                self.updateGestureRotation(x: touchLocation.x, y: touchLocation.y);
                setNeedsDisplay();
            }
        }
    }
    
    public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesEnded(touches, withEvent: event);
        
        if (rotationEnabled)
        {
            var touch = touches.first as! UITouch!;
            
            var touchLocation = touch.locationInView(self);
            
            if (isDragDecelerationEnabled)
            {
                stopDeceleration();
                
                sampleVelocity(touchLocation: touchLocation);
                
                _decelerationAngularVelocity = calculateVelocity();
                
                if (_decelerationAngularVelocity != 0.0)
                {
                    _decelerationLastTime = CACurrentMediaTime();
                    _decelerationDisplayLink = CADisplayLink(target: self, selector: Selector("decelerationLoop"));
                    _decelerationDisplayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes);
                }
            }
        }
        if (_isRotating)
        {
            self.defaultTouchEventsEnabled = _defaultTouchEventsWereEnabled;
            _isRotating = false;
        }
    }
    
    public override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesCancelled(touches, withEvent: event);
        
        if (_isRotating)
        {
            self.defaultTouchEventsEnabled = _defaultTouchEventsWereEnabled;
            _isRotating = false;
        }
    }
    
    private func resetVelocity()
    {
        _velocitySamples.removeAll(keepCapacity: false);
    }
    
    private func sampleVelocity(#touchLocation: CGPoint)
    {
        var currentTime = CACurrentMediaTime();
        
        _velocitySamples.append(AngularVelocitySample(time: currentTime, angle: angleForPoint(x: touchLocation.x, y: touchLocation.y)));
        
        // Remove samples older than our sample time - 1 seconds
        for (var i = 0, count = _velocitySamples.count; i < count - 2; i++)
        {
            if (currentTime - _velocitySamples[i].time > 1.0)
            {
                _velocitySamples.removeAtIndex(0);
                i--;
                count--;
            }
            else
            {
                break;
            }
        }
    }
    
    private func calculateVelocity() -> CGFloat
    {
        if (_velocitySamples.isEmpty)
        {
            return 0.0;
        }
        
        var firstSample = _velocitySamples[0];
        var lastSample = _velocitySamples[_velocitySamples.count - 1];
        
        // Look for a sample that's closest to the latest sample, but not the same, so we can deduce the direction
        var beforeLastSample = firstSample;
        for (var i = _velocitySamples.count - 1; i >= 0; i--)
        {
            beforeLastSample = _velocitySamples[i];
            if (beforeLastSample.angle != lastSample.angle)
            {
                break;
            }
        }
        
        // Calculate the sampling time
        var timeDelta = lastSample.time - firstSample.time;
        if (timeDelta == 0.0)
        {
            timeDelta = 0.1;
        }
        
        // Calculate clockwise/ccw by choosing two values that should be closest to each other,
        // so if the angles are two far from each other we know they are inverted "for sure"
        var clockwise = lastSample.angle >= beforeLastSample.angle;
        if (abs(lastSample.angle - beforeLastSample.angle) > 270.0)
        {
            clockwise = !clockwise;
        }
        
        // Now if the "gesture" is over a too big of an angle - then we know the angles are inverted, and we need to move them closer to each other from both sides of the 360.0 wrapping point
        if (lastSample.angle - firstSample.angle > 180.0)
        {
            firstSample.angle += 360.0;
        }
        else if (firstSample.angle - lastSample.angle > 180.0)
        {
            lastSample.angle += 360.0;
        }
        
        // The velocity
        var velocity = abs((lastSample.angle - firstSample.angle) / CGFloat(timeDelta));
        
        // Direction?
        if (!clockwise)
        {
            velocity = -velocity;
        }
        
        return velocity;
    }
    
    /// sets the starting angle of the rotation, this is only used by the touch listener, x and y is the touch position
    private func setGestureStartAngle(#x: CGFloat, y: CGFloat)
    {
        _startAngle = angleForPoint(x: x, y: y);
        
        // take the current angle into consideration when starting a new drag
        _startAngle -= _rotationAngle;
    }
    
    /// updates the view rotation depending on the given touch position, also takes the starting angle into consideration
    private func updateGestureRotation(#x: CGFloat, y: CGFloat)
    {
        self.rotationAngle = angleForPoint(x: x, y: y) - _startAngle;
    }
    
    public func stopDeceleration()
    {
        if (_decelerationDisplayLink !== nil)
        {
            _decelerationDisplayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes);
            _decelerationDisplayLink = nil;
        }
    }
    
    @objc private func decelerationLoop()
    {
        var currentTime = CACurrentMediaTime();
        
        _decelerationAngularVelocity *= self.dragDecelerationFrictionCoef;
        
        var timeInterval = CGFloat(currentTime - _decelerationLastTime);
        
        self.rotationAngle += _decelerationAngularVelocity * timeInterval;
        
        _decelerationLastTime = currentTime;
        
        if(abs(_decelerationAngularVelocity) < 0.001)
        {
            stopDeceleration();
        }
    }
    
    /// returns the distance between two points
    private func distance(#eventX: CGFloat, startX: CGFloat, eventY: CGFloat, startY: CGFloat) -> CGFloat
    {
        var dx = eventX - startX;
        var dy = eventY - startY;
        return sqrt(dx * dx + dy * dy);
    }
    
    /// returns the distance between two points
    private func distance(#from: CGPoint, to: CGPoint) -> CGFloat
    {
        var dx = from.x - to.x;
        var dy = from.y - to.y;
        return sqrt(dx * dx + dy * dy);
    }
    
    /// reference to the last highlighted object
    private var _lastHighlight: ChartHighlight!;
    
    @objc private func tapGestureRecognized(recognizer: UITapGestureRecognizer)
    {
        if (recognizer.state == UIGestureRecognizerState.Ended)
        {
            var location = recognizer.locationInView(self);
            var distance = distanceToCenter(x: location.x, y: location.y);
            
            // check if a slice was touched
            if (distance > self.radius)
            {
                // if no slice was touched, highlight nothing
                self.highlightValues(nil);
                _lastHighlight = nil;
                _lastHighlight = nil;
            }
            else
            {
                var angle = angleForPoint(x: location.x, y: location.y);
                
                if (self.isKindOfClass(PieChartView))
                {
                    angle /= _animator.phaseY;
                }
                
                var index = indexForAngle(angle);
                
                // check if the index could be found
                if (index < 0)
                {
                    self.highlightValues(nil);
                    _lastHighlight = nil;
                }
                else
                {
                    var valsAtIndex = getYValsAtIndex(index);
                    
                    var dataSetIndex = 0;
                    
                    // get the dataset that is closest to the selection (PieChart only has one DataSet)
                    if (self.isKindOfClass(RadarChartView))
                    {
                        dataSetIndex = ChartUtils.closestDataSetIndex(valsAtIndex, value: Float(distance / (self as! RadarChartView).factor), axis: nil);
                    }
                    
                    var h = ChartHighlight(xIndex: index, dataSetIndex: dataSetIndex);
                    
                    if (_lastHighlight !== nil && h == _lastHighlight)
                    {
                        self.highlightValue(highlight: nil, callDelegate: true);
                        _lastHighlight = nil;
                    }
                    else
                    {
                        self.highlightValue(highlight: h, callDelegate: true);
                        _lastHighlight = h;
                    }
                }
            }
        }
    }
}