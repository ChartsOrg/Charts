//
//  AxisChartView.swift
//  GenieApp
//
//  Created by Tomas Friml on 12/01/17.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts

import UIKit.UIGestureRecognizerSubclass

// MARK: - ImmediatePanGestureRecognizer
fileprivate class ImmediatePanGestureRecognizer : UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began {
            _touchDelayTimer?.invalidate()
            return
        } else if _touchDelayTimer == nil || _touchDelayTimer?.isValid == false {
            // added slight delay because of pinch gesture
            _touchDelayTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(beginTouches), userInfo: nil, repeats: false)
        }
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Private
    fileprivate var _touchDelayTimer : Timer? = nil
    
    @objc fileprivate func beginTouches() {
        self.state = .began
        _touchDelayTimer?.invalidate()
    }
}

// MARK: - InteractiveChartViewDelegate
@objc
public protocol InteractiveChartViewDelegate : ChartViewDelegate {
    func chartValueMoved(_ chartView: ChartViewBase, entry: ChartDataEntry, touchFinished: Bool)
    func chartDataSetSelected(_ chartView: ChartViewBase, dataSet: ChartDataSet?)
}

// MARK: - InteractiveChartView
open class InteractiveChartView: BarLineChartViewBase, LineChartDataProvider {
    /// Tap/drag distance from the point/line for the touch to recognize the selection
    open var touchPointDistance : CGFloat = 15
    /// Only allow selection when set was selected first
    open var selectWhenSetSelected = false
    
    /// delegate to receive chart events
    open weak var interactiveDelegate: InteractiveChartViewDelegate?
    override weak open var delegate: ChartViewDelegate? {
        didSet {
           interactiveDelegate = delegate as? InteractiveChartViewDelegate
        }
    }
    
    // MARK: - LineChartDataProvider
    open var lineData: LineChartData? { return data as? LineChartData }
    
    open override func notifyDataSetChanged() {
        super.notifyDataSetChanged()
        
        // refresh selected data
        if let data = _selectedData {
            if let entry = data.set.entryForIndex(data.index) {
                _selectedData?.entry = entry
                highlightValue(x: entry.x, y: entry.y, dataSetIndex: data.setIndex, callDelegate: false)
            }
        }
    }
    
    open override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if super.gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) == false {
            return gestureRecognizer.isKind(of: ImmediatePanGestureRecognizer.self)
                && (otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self) || otherGestureRecognizer.isKind(of: UIPinchGestureRecognizer.self))
        }
        return false
    }
    
    /// Tries to find the dataset at current touch point
    /// NOTE: this only works for line chart not say bezier
    /// You can override and implement different ones for different types of graphs
    ///
    /// - Parameter pt: Touch point
    open func getSelectedDataSetAtTouchPoint(point pt: CGPoint) -> ChartDataSet? {
        func sqr(x: CGFloat) -> CGFloat { return x*x }
        
        guard let d = data else {
            return nil
        }
        
        let maxDistance_pt : CGFloat = 25  // maximal allowed distance from the axis to select it in points
        
        let valuePoint = getTransformer(forAxis: .left).valueForTouchPoint(pt)
        let touchX = Double(valuePoint.x)
        let touchY = Double(valuePoint.y)
        
        var minDistance = CGFloat.greatestFiniteMagnitude
        var selectedSet : IChartDataSet?
        
        for set in d.dataSets {
            if let closestEntry = set.entryForXValue(touchX, closestToY: touchY, rounding: .up) {
                let index = set.entryIndex(entry: closestEntry)
                var smallerEntry : ChartDataEntry?
                var greaterEntry : ChartDataEntry?
                
                // have to calculate maximal allowed distance based on values and max pt distance from the line
                let transformer = getTransformer(forAxis: set.axisDependency)
                
                let y1 = transformer.valueForTouchPoint(CGPoint(x: pt.x, y: pt.y+maxDistance_pt))
                let y2 = transformer.valueForTouchPoint(CGPoint(x: pt.x, y: pt.y-maxDistance_pt))
                let maxAllowedDistance = abs(y1.y - y2.y)
                
                if closestEntry.x >= touchX {
                    let nIndex = index - 1
                    assert(nIndex >= 0)
                    if nIndex >= 0 {
                        smallerEntry = set.entryForIndex(nIndex)
                        greaterEntry = closestEntry
                    }
                } else {
                    let nIndex = index + 1
                    assert(nIndex < set.entryCount)
                    if nIndex < set.entryCount {
                        smallerEntry = closestEntry
                        greaterEntry = set.entryForIndex(nIndex)
                    }
                }
                
                if let sEntry = smallerEntry, let gEntry = greaterEntry {
                    // found two value surrounding the touch
                    let sPoint = transformer.pixelForValues(x: sEntry.x, y: sEntry.y)
                    let ePoint = transformer.pixelForValues(x: gEntry.x, y: gEntry.y)
                    let dist = distanceToLineSegment(from: pt, v: sPoint, w: ePoint)
                    
                    if dist <= maxAllowedDistance && dist < minDistance {
                        //NSLog("Better distance: \(dist), p1: \(sPoint), p2: \(ePoint)")
                        minDistance = dist
                        selectedSet = set
                    }
                }
            }
        }
        
        return selectedSet as? ChartDataSet
    }
    
    
    
    // MARK: - Private
    fileprivate var _isDragging = false
    fileprivate var _isDraggingPoint = false
    fileprivate var _selectedData : ChartSelectedData? = nil
    fileprivate var _selectedDataSet : ChartDataSet? = nil
    
    fileprivate struct ChartSelectedData {
        let setIndex : Int
        let set : ChartDataSet
        let index : Int
        var entry : ChartDataEntry
    }
    
    fileprivate var _decelerationLastTime: TimeInterval = 0.0
    fileprivate var _decelerationDisplayLink: NSUIDisplayLink!
    fileprivate var _decelerationVelocity = CGPoint()
    
    fileprivate var _lastPanPoint = CGPoint() /// This is to prevent using setTranslation which resets velocity
    
    internal override func initialize() {
        super.initialize()
        
        renderer = LineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        // reset gesture actions
        _tapGestureRecognizer.removeTarget(self, action: nil)
        _tapGestureRecognizer.addTarget(self, action: #selector(interactiveTapGestureRecognized(_:)))
        
        // use subclassed pan gesture recognizer to get rid of the min pan distance delay
        _panGestureRecognizer = ImmediatePanGestureRecognizer(target: self, action: #selector(interactivePanGestureRecognized(_:)))
        _panGestureRecognizer.delegate = self
        _panGestureRecognizer.maximumNumberOfTouches = 1
        addGestureRecognizer(_panGestureRecognizer)
        
        // this prevent long delays between double taps
        _doubleTapGestureRecognizer.shouldRequireFailure(of: _tapGestureRecognizer)
    }
    
    
    @objc fileprivate func interactiveTapGestureRecognized(_ recognizer: NSUITapGestureRecognizer) {
        stopDeceleration()
        
        if data === nil
        { // If we have no data, we have nothing to pan and no data to highlight
            return
        }
        
        var selectDataSet = true
        let touchPoint = recognizer.location(ofTouch: 0, in: self)
        
        if selectWhenSetSelected == false || _selectedDataSet != nil {
            if let selectedData = getSelectedChartDataAtTouchPoint(point: touchPoint) {
                _selectedData = selectedData
                if selectedData.set == _selectedDataSet {
                    updateHighlight(for: pixelForValues(x: selectedData.entry.x, y: selectedData.entry.y, axis: selectedData.set.axisDependency))
                    selectDataSet = false
                }
            }
        } else {
            _selectedData = nil
        }
        
        if selectDataSet {
            if let selectedDataSet = getSelectedDataSetAtTouchPoint(point: touchPoint) {
                if selectedDataSet != _selectedDataSet {
                    _selectedDataSet = selectedDataSet
                } else {
                    _selectedDataSet = nil
                    if selectWhenSetSelected {
                        // deselect the point when set has to be selected first
                        _selectedData = nil
                        highlightValue(nil, callDelegate: true)
                        lastHighlighted = nil
                    }
                }
                interactiveDelegate?.chartDataSetSelected(self, dataSet: _selectedDataSet)
            }
        }
        
    }
    
    @objc fileprivate func interactivePanGestureRecognized(_ recognizer: NSUIPanGestureRecognizer)
    {
        if recognizer.state == NSUIGestureRecognizerState.began && recognizer.numberOfTouches > 0
        {
            stopDeceleration()
            
            if data === nil
            { // If we have no data, we have nothing to pan and no data to highlight
                return
            }
            
            // If drag is enabled and we are in a position where there's something to drag:
            if self.isDragEnabled
            {
                
                // figure out if user touched entry
                let touchPoint = recognizer.location(ofTouch: 0, in: self)
                let selectedData : ChartSelectedData? = (selectWhenSetSelected == false || _selectedDataSet != nil) ? getSelectedChartDataAtTouchPoint(point: touchPoint) : nil
                
                // are we touching a point
                _isDraggingPoint = selectedData != nil
                
                if _isDraggingPoint {
                    _selectedData = selectedData
                    self._isDragging = true
                } else if (!self.hasNoDragOffset || !self.isFullyZoomedOut) {
                    //  * If we're zoomed in, then obviously we have something to drag.
                    //  * If we have a drag offset - we always have something to drag
                    self._isDragging = true
                    
                    _lastPanPoint = recognizer.translation(in: self)
                }
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.changed
        {
            if _isDragging
            {
                if _isDraggingPoint {
                    if let selectedData = _selectedData {
                        // update entry values
                        let location = recognizer.location(in: self)
                        let value = valueForTouchPoint(point: location, axis: selectedData.set.axisDependency)
                        
                        // check if we haven't passed the previous point or next one
                        var canUpdateEntryX = true
                        let newX = Double(value.x)
                        let newY = Double(value.y)
                        
                        if selectedData.set.entryForIndex(selectedData.index) != nil {
                            
                            if selectedData.index > 0 {
                                if let prevEntry = selectedData.set.entryForIndex(selectedData.index-1) {
                                    canUpdateEntryX = newX > prevEntry.x
                                }
                            } else {
                                // only allow vertical movement for first point
                                canUpdateEntryX = false
                            }
                            if canUpdateEntryX {
                                if selectedData.index < selectedData.set.entryCount-1 {
                                    if let nextEntry = selectedData.set.entryForIndex(selectedData.index+1) {
                                        canUpdateEntryX = newX < nextEntry.x
                                    }
                                } else {
                                    // only allow vertical movement for last point
                                    canUpdateEntryX = false
                                }
                            }
                            
                            var canUpdate = canUpdateEntryX
                            if canUpdateEntryX {
                                selectedData.entry.x = Double(newX)
                            }
                            
                            if newY <= leftAxis.axisMaximum && newY >= leftAxis.axisMinimum {
                                selectedData.entry.y = Double(newY)
                                canUpdate = true
                            }
                            
                            updateHighlightAfterMove(for: pixelForValues(x: selectedData.entry.x, y: selectedData.entry.y, axis: selectedData.set.axisDependency))
                            if canUpdate {
                                //NSLog("Moved - x:\(newX), y: \(newY)")
                                interactiveDelegate?.chartValueMoved(self, entry: selectedData.entry, touchFinished: false)
                            }
                            
                            // NOTE: use below to snap the highlight while it's moving
                            //NSLog("Highlight - x:\(selectedData.entry.x), y: \(selectedData.entry.y)")
                            //updateHighlightAfterMove(for: pixelForValues(x: selectedData.entry.x, y: selectedData.entry.y, axis: selectedData.set.axisDependency))
                        }
                        
                        // redraw the chart
                        setNeedsDisplay()
                    }
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
                    
                    _decelerationDisplayLink = NSUIDisplayLink(target: self, selector: #selector(InteractiveChartView.decelLoop))
                    _decelerationDisplayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
                }
            
                if _isDraggingPoint, let selectedData = _selectedData {
                    interactiveDelegate?.chartValueMoved(self, entry: selectedData.entry, touchFinished: true)
                    updateHighlightAfterMove(for: pixelForValues(x: selectedData.entry.x, y: selectedData.entry.y, axis: selectedData.set.axisDependency))
                }
                
                _isDragging = false
                _isDraggingPoint = false
            }
        }
    }
    
    fileprivate func updateHighlight(for point:CGPoint) {
        if !self.isHighLightPerTapEnabled { return }
        
        if let h = getHighlightByTouchPoint(point) {
            if h.isEqual(self.lastHighlighted) {
                self.highlightValue(nil, callDelegate: true)
                self.lastHighlighted = nil
            } else {
                self.highlightValue(h, callDelegate: true)
                self.lastHighlighted = h
            }
        }
    }
    
    fileprivate func updateHighlightAfterMove(for point:CGPoint) {
        if !self.isHighLightPerTapEnabled { return }
        
        if let h = getHighlightByTouchPoint(point) {
            self.highlightValue(h, callDelegate: true)
            self.lastHighlighted = h
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
            
            if let setIndex = data?.indexOfDataSet(closestDataSet) {
                if selectedEntryIndex != Int.max {
                    return ChartSelectedData(setIndex: setIndex, set: closestDataSet as! ChartDataSet, index: selectedEntryIndex, entry: closestDataSet.entryForIndex(selectedEntryIndex)!)
                }
            }
        }
        
        return nil
    }
    
    
    /// Calculates the (shortest) distance between point pt and line segment (v,w)
    /// SEE: http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    ///
    /// - Parameters:
    ///   - pt: Point to calculate the distance to
    ///   - v: Line segment start
    ///   - w: Line segment end
    /// - Returns: The shortest distance from (v,w) to pt
    fileprivate func distanceToLineSegment(from p:CGPoint, v:CGPoint, w:CGPoint) -> CGFloat {
        func sqr(x: CGFloat) -> CGFloat { return x*x }
        func dist2(v: CGPoint, w: CGPoint) -> CGFloat { return sqr(x: v.x - w.x) + sqr(x: v.y - w.y) }
        func dist(dist2: CGFloat) -> CGFloat { return CGFloat(sqrtf(Float(dist2))) }
        
        let l2 = dist2(v: v, w: w)
        if l2 == 0 {
            return dist(dist2: dist2(v: p, w: v))
        }
        
        var t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
        t = max(0, min(1, t))
        
        return dist(dist2: dist2(v: p, w: CGPoint(x: v.x + t * (w.x - v.x), y: v.y + t * (w.y - v.y))))
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
            //calculateOffsets()
            setNeedsDisplay()
        }
    }

    open override func stopDeceleration()
    {
        if _decelerationDisplayLink !== nil
        {
            _decelerationDisplayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            _decelerationDisplayLink = nil
        }
    }
}
