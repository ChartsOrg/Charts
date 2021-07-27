//
//  BarLineChartViewBase+CustomDraw.swift
//  Charts
//
//  Created by JustLee on 2021/4/1.
//

import Foundation
import UIKit
import CoreGraphics

extension BarLineChartViewBase {
    
    
    /// locate the gesture point for the custom draw data entry
    /// - Parameter touchPoint: touchPoint description
    /// - Returns: optional custom draw entry
    private func locateCustomDataEntry(touchPoint: CGPoint) -> CustomDrawChartDataEntry?
    {
        guard let dataSets = customDrawData?.dataSets as? [CustomDrawChartDataSet] else { return nil }
        
        for dataSet in dataSets {
            let valuePoint = valueForTouchPoint(point: touchPoint, axis: dataSet.axisDependency)
            if let entry = dataSet.locateTouchEntry(touchPoint: valuePoint, xRange: CGFloat(highestVisibleX - lowestVisibleX), yRange: CGFloat(chartYMax - chartYMin)) {
                return entry
            }
        }
        return nil
    }
    
    private func locateCustomDataEntry(dataSet: CustomDrawChartDataSet?, touchPoint: CGPoint) -> CustomDrawChartDataEntry?
    {
        guard let dataSet = dataSet else { return nil }
        
        let valuePoint = valueForTouchPoint(point: touchPoint, axis: dataSet.axisDependency)
        if let entry = dataSet.locateTouchEntry(touchPoint: valuePoint, xRange: CGFloat(highestVisibleX - lowestVisibleX), yRange: CGFloat(chartYMax - chartYMin)) {
            return entry
        }
        return nil
    }
     
    
    /// locate the gesture point for custom draw dataset
    /// Find the dataset  through the entry, using locateCustomDataEntry(touchPoint:)
    /// - Parameter touchPoint: touchPoint description
    /// - Returns: description
    private func locateCustomDataSet(touchPoint: CGPoint) -> CustomDrawChartDataSet?
    {
        guard let dataSets = customDrawData?.dataSets as? [CustomDrawChartDataSet] else { return nil }
        
        let entry = locateCustomDataEntry(touchPoint: touchPoint)
        for dataSet in dataSets {
            if entry !== nil && dataSet.contains(entry!) {
                return dataSet
            }
            ///the touch point locate a dataset with custom draw bezier path
            if dataSet.calculatePositionInGraphics(touchPoint: touchPoint) {
                return dataSet
            }
        }
    
        return nil
    }
    
    
    /// add a new graphics through the custom dataset
    /// - Parameter dataSet: dataSet description
    @objc open func addCustomDrawGraphics(dataSet: CustomDrawChartDataSet)
    {
        guard let customDrawData = customDrawData else { return }
        
        //if in custom drawing or editing, clear current unfinished data
        if combinedCustomDrawGraphicsState {
            clearCustomDrawState()
        }
        /// set drawing state to yes
        drawingCustomGraphics = true
        /// set editing draw dataset
        editingDrawDataSet = dataSet
        /// add dataset to custom draw data
        customDrawData.append(dataSet)
    }
    
    /// the state for custom graphics drawing or editing
    @objc open var combinedCustomDrawGraphicsState: Bool
    {
        get {
            return (drawingCustomGraphics || editingCustomGraphics) && (editingDrawDataEntry !== nil || editingDrawDataSet !== nil)
        }
    }

    /// append custom draw entry with touch point
    /// - Parameter pt: 触摸点
    open func appendCustomDrawGraphicsEntry(touchPoint: CGPoint)
    {
        guard enableDrawCustomGraphics,
              let customDrawData = customDrawData,
              let editingDrawDataSet = editingDrawDataSet
               else {
            return
        }
        
        let valuePoint = valueForTouchPoint(point: touchPoint, axis: editingDrawDataSet.axisDependency)
        editingDrawDataEntry = CustomDrawChartDataEntry(x: Double(valuePoint.x), y: Double(valuePoint.y))
        editingDrawDataSet.append(editingDrawDataEntry!)
        
        /// set the highlighted index
        self.customGraphicsHighlighted = [Highlight(x: 0, dataSetIndex: customDrawData.index(of: editingDrawDataSet), stackIndex: 0)]

        /// if the graphics has finished, change the state for drawing & editing
        if editingDrawDataSet.dataSetCompletedCustomDraw {
            drawingCustomGraphics = false
            editingCustomGraphics = true
        }
        
        setNeedsDisplay()
        
        performCustomDrawActionEndDelegate()
    }
    
    /// clear custom draw state
    open func clearCustomDrawState()
    {
        // remove pervious highlighted graphics state
        self.customGraphicsHighlighted.removeAll()
        
        /// if the chart has a unfinished custom draw graphics action
        if let customDrawData = customDrawData, let dataSet = editingDrawDataSet, drawingCustomGraphics {
            customDrawData.removeDataSet(dataSet)
        }
        
        // set edit object to nil
        editingDrawDataSet = nil
        editingDrawDataEntry = nil
        
        setNeedsDisplay()
    }
    
    /// through the touch point reset editing custom draw entry & dataset
    /// - Parameter touchPoint: touchPoint
    open func resetEditCustomGraphicsDataSet(touchPoint: CGPoint, moving: Bool) -> Bool
    {
        if let customDrawData = customDrawData, let dataSet = locateCustomDataSet(touchPoint: touchPoint) {
            editingDrawDataEntry = locateCustomDataEntry(dataSet: dataSet, touchPoint: touchPoint)

            if moving {
                if editingDrawDataSet != nil {
                    return editingDrawDataSet === dataSet
                }
            }
            
            editingDrawDataSet = dataSet

            ///move the selected graphics to the front
            if customDrawData.dataSetCount > 1 {
                customDrawData.dataSets.swapAt(0, customDrawData.index(of: dataSet))
            }
            /// reset custom graphics highlighted
            self.customGraphicsHighlighted = [Highlight(x: 0, dataSetIndex: customDrawData.index(of: dataSet), stackIndex: 0)]
            
            setNeedsDisplay()
            
            return true
        } else {
            //if touch point didn't locate a graphics path, clear the pervious state
            clearCustomDrawState()
            return false
        }
    }
    
    
    /// the condition with gesture enable interrupt, make the custom draw action continue
    /// - Parameter touchPoint: touch point
    open func customDrawInterruptGesture(touchPoint: CGPoint) -> Bool
    {
        if !enableDrawCustomGraphics {
            return false
        }
        /// the new graphics aren't unfinished
        if drawingCustomGraphics {
            appendCustomDrawGraphicsEntry(touchPoint: touchPoint)
            return true
        }
        /// find the editing graphic dataset through gesture point
        return resetEditCustomGraphicsDataSet(touchPoint: touchPoint, moving: false)
    }
    
    /// the condition with gesture enable interrupt, make the custom draw action continue
    /// - Parameter touchPoint: touch point
    open func customDrawInterruptMovingGesture(touchPoint: CGPoint) -> Bool
    {
        if !enableDrawCustomGraphics {
            return false
        }
        /// the new graphics aren't unfinished
        if drawingCustomGraphics {
            appendCustomDrawGraphicsEntry(touchPoint: touchPoint)
            return true
        }
        /// find the editing graphic dataset through gesture point
        return resetEditCustomGraphicsDataSet(touchPoint: touchPoint, moving: true)
    }
    
    /// calculate the distance with gesture location
    /// - Parameters:
    ///   - previousPoint: previousPoint description
    ///   - currentPoint: currentPoint description
    /// - Returns: description
    private func moveDistancePoint(previousPoint: CGPoint, currentPoint: CGPoint) -> CGPoint
    {
        guard let dataSet = editingDrawDataSet else {
            return .zero
        }
        
        let currentPointValue = valueForTouchPoint(point: currentPoint, axis: dataSet.axisDependency)
        let previousPointValue = valueForTouchPoint(point: previousPoint, axis: dataSet.axisDependency)
        return CGPoint(x: currentPointValue.x - previousPointValue.x, y: currentPointValue.y - previousPointValue.y)
    }
    
    /// move the graphics through previousPoint & currentPoint
    /// - Parameters:
    ///   - previousPoint: previousPoint description
    ///   - currentPoint: currentPoint description
    open func moveCustomDrawDataSet(previousPoint: CGPoint, currentPoint: CGPoint)
    {
        if combinedCustomDrawGraphicsState {
            moveCustomDrawGraphicsDataSet(translation: moveDistancePoint(previousPoint: previousPoint, currentPoint: currentPoint))
            customDrawDelegate?.customDrawTouchPointChanged?(self, touchPoint: currentPoint)
        }
    }
    
    ///move the graphics with gesture, if the editingDrawDataEntry is not nil, move single editing entry, or move the whole graphics
    open func moveCustomDrawGraphicsDataSet(translation: CGPoint)
    {
        if !combinedCustomDrawGraphicsState {
            return
        }
        
        if let dataSet = editingDrawDataSet {
            if let entry = editingDrawDataEntry {
                dataSet.singleEntryMove(entry: entry, translation: translation)
            } else {
                dataSet.totalGraphicsMove(translation: translation)
            }
            setNeedsDisplay()
        }
    }
    
    open func performCustomDrawActionEndDelegate()
    {
        if let customDrawDelegate = customDrawDelegate {
            customDrawDelegate.customDrawActionCompleted?(self, dataSet: editingDrawDataSet!)
        }
    }
    
    open func performCustomDrawDataSetDidSelectedDelegate()
    {
        if let customDrawDelegate = customDrawDelegate, let dataSet = editingDrawDataSet {
            customDrawDelegate.customDrawDataSetDidSelected?(self, dataSet: dataSet)
        }
    }
    
    open func performCustomDrawDataSetDesSelectedDelegate()
    {
        if let customDrawDelegate = customDrawDelegate, let dataSet = editingDrawDataSet {
            customDrawDelegate.customDrawDataSetDeselected?(self, dataSet: dataSet)
        }
    }
 
    open override func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        if let touch = touches.first {
            if customDrawInterruptMovingGesture(touchPoint: touch.location(in: self)) {
                moveCustomDrawDataSet(previousPoint: touch.previousLocation(in: self), currentPoint: touch.location(in: self))
                return
            }
        }
        super.nsuiTouchesMoved(touches, withEvent: event)
    }
}
