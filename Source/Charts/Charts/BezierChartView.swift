//
//  BezierChartView.swift
//  Charts
//
//  Created by Tomas Friml on 14/10/16.
//
//

import UIKit

open class BezierChartView: BarLineChartViewBase, LineChartDataProvider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var touchPointDistance : CGFloat = 25
    
    fileprivate weak var _outerScrollView: NSUIScrollView?
    fileprivate var _decelerationLastTime: TimeInterval = 0.0
    fileprivate var _decelerationDisplayLink: NSUIDisplayLink!
    fileprivate var _decelerationVelocity = CGPoint()
    
    fileprivate var _lastPanPoint = CGPoint() /// This is to prevent using setTranslation which resets velocity
    
    override func initialize() {
        super.initialize()
        
        renderer = BezierChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        if let recognizer = _panGestureRecognizer {
            self.removeGestureRecognizer(recognizer)
        }
        
        _panGestureRecognizer = NSUIPanGestureRecognizer(target: self, action: #selector(onPanGestureRecognized(_:)))
        _panGestureRecognizer.delegate = self
        self.addGestureRecognizer(_panGestureRecognizer)
        
        self.highlightPerTapEnabled = true
        self.highlightPerDragEnabled = true
    }
    
    // MARK: - LineChartDataProvider
    
    open var lineData: LineChartData? { return _data as? LineChartData }
    
    
    
    // MARK: - Private
    fileprivate var _isDragging = false
    fileprivate var _selectedData : ChartSelectedData?
    
    fileprivate struct ChartSelectedData {
        let dataSet : ChartDataSet
        let index : Int
        let entry : ChartDataEntry
    }
    
    @objc fileprivate func onPanGestureRecognized(_ recognizer: NSUIPanGestureRecognizer)
    {
        if recognizer.state == NSUIGestureRecognizerState.began && recognizer.nsuiNumberOfTouches() > 0
        {
            stopDeceleration()
            
            if _data === nil
            { // If we have no data, we have nothing to pan and no data to highlight
                return
            }
            
            // If drag is enabled and we are in a position where there's something to drag:
            if self.isDragEnabled
            {
                
                // figure out if user touched entry
                _selectedData = getSelectedChartDataAtTouchPoint(point: recognizer.nsuiLocationOfTouch(0, inView: self))
                
                if _selectedData != nil {
                    self._isDragging = true
                } else if (!self.hasNoDragOffset || !self.isFullyZoomedOut) {
                    //  * If we're zoomed in, then obviously we have something to drag.
                    //  * If we have a drag offset - we always have something to drag
                    self._isDragging = true
                    
                    let translation = recognizer.translation(in: self)
                    let didUserDrag = translation.x != 0.0
                    
                    // Check to see if user dragged at all and if so, can the chart be dragged by the given amount
                    if didUserDrag && !performPanChange(translation: translation)
                    {
                        if _outerScrollView !== nil
                        {
                            // We can stop dragging right now, and let the scroll view take control
                            _outerScrollView = nil
                            _isDragging = false
                        }
                    }
                    else
                    {
                        if _outerScrollView !== nil
                        {
                            // Prevent the parent scroll view from scrolling
                            _outerScrollView?.nsuiIsScrollEnabled = false
                        }
                    }
                    
                    _lastPanPoint = recognizer.translation(in: self)
                }
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.changed
        {
            if _isDragging
            {
                if let selectedData = _selectedData {
                    // update entry values
                    let location = recognizer.location(in: self)
                    let value = valueForTouchPoint(point: location, axis: selectedData.dataSet.axisDependency)
                    
                    // check if we haven't passed the previous point or next one
                    var canUpdateEntryX = true
                    let newX = Double(value.x)
                    let newY = Double(value.y)
                    
                    if selectedData.index > 0 {
                        if let prevEntry = selectedData.dataSet.entryForIndex(selectedData.index-1) {
                            canUpdateEntryX = newX > prevEntry.x
                        }
                    } else {
                        // only allow vertical movement for first point
                        canUpdateEntryX = false
                    }
                    if canUpdateEntryX {
                        if selectedData.index < selectedData.dataSet.entryCount-1 {
                            if let nextEntry = selectedData.dataSet.entryForIndex(selectedData.index+1) {
                                canUpdateEntryX = newX < nextEntry.x
                            }
                        } else {
                            // only allow vertical movement for last point
                            canUpdateEntryX = false
                        }
                    }
                    
                    if canUpdateEntryX {
                        selectedData.entry.x = newX
                    }
                    if newY <= leftAxis.axisMaximum && newY >= leftAxis.axisMinimum {
                        selectedData.entry.y = newY
                    }
                    
                    // redraw the chart
                    setNeedsDisplay()
                } else {
                    let originalTranslation = recognizer.translation(in: self)
                    let translation = CGPoint(x: originalTranslation.x - _lastPanPoint.x, y: originalTranslation.y - _lastPanPoint.y)
                    
                    let _ = performPanChange(translation: translation)
                    
                    _lastPanPoint = originalTranslation
                }
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.ended || recognizer.state == NSUIGestureRecognizerState.cancelled
        {
            if _isDragging
            {
                if recognizer.state == NSUIGestureRecognizerState.ended && isDragDecelerationEnabled
                {
                    stopDeceleration()
                    
                    _decelerationLastTime = CACurrentMediaTime()
                    _decelerationVelocity = recognizer.velocity(in: self)
                    
                    _decelerationDisplayLink = NSUIDisplayLink(target: self, selector: #selector(BezierChartView.decelLoop))
                    _decelerationDisplayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
                }
                
                _isDragging = false
            }
            
            if _outerScrollView !== nil
            {
                _outerScrollView?.nsuiIsScrollEnabled = true
                _outerScrollView = nil
            }
        }
    }
    
    /// - returns: Selected chart data if within specified distance
    fileprivate func getSelectedChartDataAtTouchPoint(point pt: CGPoint) -> ChartSelectedData?
    {
        // find closes dataset
        if let closestDataSet = getDataSetByTouchPoint(point: pt) {
            var closestDistance : CGFloat = touchPointDistance
            var selectedEntryIndex = Int.max
            
            // find entry within dataset
            for i in 0 ..< closestDataSet.entryCount {
                if let entry = closestDataSet.entryForIndex(i) {
                    let px = getTransformer(forAxis: closestDataSet.axisDependency).pixelForValues(x: entry.x, y: entry.y)
                    let distance = hypot(pt.x - px.x, pt.y - px.y)
                    
                    if distance < closestDistance && distance < touchPointDistance {
                        closestDistance = distance
                        selectedEntryIndex = i
                    }
                }
            }
            
            if selectedEntryIndex != Int.max {
                return ChartSelectedData(dataSet: closestDataSet as! ChartDataSet, index: selectedEntryIndex, entry: closestDataSet.entryForIndex(selectedEntryIndex)!)
            }
        }
        
        return nil
    }
    
    fileprivate func performPanChange(translation: CGPoint) -> Bool
    {
        let originalMatrix = _viewPortHandler.touchMatrix
        
        var matrix = CGAffineTransform(translationX: translation.x, y: translation.y)
        matrix = originalMatrix.concatenating(matrix)
        
        matrix = _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
        
        if delegate !== nil
        {
            delegate?.chartTranslated?(self, dX: translation.x, dY: translation.y)
        }
        
        // Did we managed to actually drag or did we reach the edge?
        return matrix.tx != originalMatrix.tx || matrix.ty != originalMatrix.ty
    }
    
    @objc fileprivate func decelLoop()
    {
        let currentTime = CACurrentMediaTime()
        
        _decelerationVelocity.x *= self.dragDecelerationFrictionCoef
        _decelerationVelocity.y *= self.dragDecelerationFrictionCoef
        
        let timeInterval = CGFloat(currentTime - _decelerationLastTime)
        
        let distance = CGPoint(
            x: _decelerationVelocity.x * timeInterval,
            y: _decelerationVelocity.y * timeInterval
        )
        
        if !performPanChange(translation: distance)
        {
            // We reached the edge, stop
            _decelerationVelocity.x = 0.0
            _decelerationVelocity.y = 0.0
        }
        
        _decelerationLastTime = currentTime
        
        if abs(_decelerationVelocity.x) < 0.001 && abs(_decelerationVelocity.y) < 0.001
        {
            stopDeceleration()
            
            // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
            calculateOffsets()
            setNeedsDisplay()
        }
    }
}
