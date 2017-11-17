//
//  ScatterChartRenderer.swift
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


@objc
open class ScatterChartRenderer: NSObject, LineScatterCandleRadarRenderer
{
    typealias XBounds = CountableClosedRange<Int>

    var xBounds: XBounds!

    @objc public var animator: Animator?

    @objc public var viewPortHandler: ViewPortHandler

    @objc open weak var dataProvider: ScatterChartDataProvider?
    
    @objc public init(dataProvider: ScatterChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler)
    {
        self.animator = animator
        self.viewPortHandler = viewPortHandler
        self.dataProvider = dataProvider
    }
    
    open func drawData(context: CGContext)
    {
        guard let scatterData = dataProvider?.scatterData else { return }
        
        for i in 0 ..< scatterData.dataSetCount
        {
            guard let set = scatterData.getDataSetByIndex(i) else { continue }
            
            if set.isVisible
            {
                if !(set is IScatterChartDataSet)
                {
                    fatalError("Datasets for ScatterChartRenderer must conform to IScatterChartDataSet")
                }
                
                drawDataSet(context: context, dataSet: set as! IScatterChartDataSet)
            }
        }
    }
    
    fileprivate var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: IScatterChartDataSet)
    {
        guard
            let dataProvider = dataProvider,
            let animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        
        var point = CGPoint()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if let renderer = dataSet.shapeRenderer
        {
            context.saveGState()
            
            for j in 0 ..< Int(min(ceil(Double(entryCount) * animator.phaseX), Double(entryCount)))
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                point.x = CGFloat(e.x)
                point.y = CGFloat(e.y * phaseY)
                point = point.applying(valueToPixelMatrix)
                
                if !viewPortHandler.isInBoundsRight(point.x)
                {
                    break
                }
                
                if !viewPortHandler.isInBoundsLeft(point.x) ||
                    !viewPortHandler.isInBoundsY(point.y)
                {
                    continue
                }
                
                renderer.renderShape(context: context, dataSet: dataSet, viewPortHandler: viewPortHandler, point: point, color: dataSet.color(atIndex: j))
            }
            
            context.restoreGState()
        }
        else
        {
            print("There's no IShapeRenderer specified for ScatterDataSet", terminator: "\n")
        }
    }
    
    open func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let scatterData = dataProvider.scatterData,
            let animator = animator
            else { return }
        
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            guard let dataSets = scatterData.dataSets as? [IScatterChartDataSet] else { return }
            
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< scatterData.dataSetCount
            {
                let dataSet = dataSets[i]
                
                if !shouldDrawValues(forDataSet: dataSet)
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                let shapeSize = dataSet.scatterShapeSize
                let lineHeight = valueFont.lineHeight
                
                xBounds = XBounds(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                for j in xBounds
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    // make sure the lines don't do shitty things outside bounds
                    if (!viewPortHandler.isInBoundsLeft(pt.x)
                        || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    let text = formatter.stringForValue(
                        e.y,
                        entry: e,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler)
                    
                    if dataSet.isDrawValuesEnabled
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: text,
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y - shapeSize - lineHeight),
                            align: .center,
                            attributes: [NSAttributedStringKey.font: valueFont, NSAttributedStringKey.foregroundColor: dataSet.valueTextColorAt(j)]
                        )
                    }
                    
                    if let icon = e.icon, dataSet.isDrawIconsEnabled
                    {
                        ChartUtils.drawImage(context: context,
                                             image: icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size)
                    }
                }
            }
        }
    }
    
    open func drawExtras(context: CGContext)
    {
        
    }
    
    open func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let scatterData = dataProvider.scatterData,
            let animator = animator
            else { return }
        
        context.saveGState()
        
        for high in indices
        {
            guard
                let set = scatterData.getDataSetByIndex(high.dataSetIndex) as? IScatterChartDataSet,
                set.isHighlightEnabled
                else { continue }
            
            guard let entry = set.entryForXValue(high.x, closestToY: high.y) else { continue }
            
            if !isInBoundsX(entry: entry, dataSet: set) { continue }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let x = entry.x // get the x-position
            let y = entry.y * Double(animator.phaseY)
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            let pt = trans.pixelForValues(x: x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
        
        context.restoreGState()
    }
}

// MARK: DataRender
// TODO: Can be removed when dropping Objective-C compatibility
extension ScatterChartRenderer {
    public func initBuffers() {

    }

    public func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool {
        guard let data = dataProvider?.data else { return false }
        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * self.viewPortHandler.scaleX)
    }
}
