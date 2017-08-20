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


open class ScatterChartRenderer: LineScatterCandleRadarRenderer
{
    open weak var dataProvider: ScatterChartDataProvider?
    
    public init(dataProvider: ScatterChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext)
    {
        guard let scatterData = dataProvider?.scatterData else { return }
        
        for case let set as IScatterChartDataSet in scatterData.dataSets where set.isVisible
        {
            drawDataSet(context: context, dataSet: set)
        }
    }
    
    fileprivate var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    open func drawDataSet(context: CGContext, dataSet: IScatterChartDataSet)
    {
        guard
            let dataProvider = dataProvider,
            let animator = animator,
            let viewPortHandler = self.viewPortHandler
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        
        var point = CGPoint()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if let renderer = dataSet.shapeRenderer
        {
            context.saveGState()
            defer { context.restoreGState() }

            for j in 0 ..< Int(min(ceil(CGFloat(entryCount) * animator.phaseX), CGFloat(entryCount)))
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                point.x = CGFloat(e.x)
                point.y = CGFloat(e.y) * phaseY
                point = point.applying(valueToPixelMatrix)
                
                guard viewPortHandler.isInBoundsRight(point.x) else { break }
                
                guard viewPortHandler.isInBoundsLeft(point.x),
                    viewPortHandler.isInBoundsY(point.y)
                    else { continue }
                
                renderer.renderShape(context: context, dataSet: dataSet, viewPortHandler: viewPortHandler, point: point, color: dataSet.color(atIndex: j))
            }
        }
        else
        {
            debugPrint("There's no IShapeRenderer specified for ScatterDataSet", terminator: "\n")
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        guard let dataProvider = dataProvider,
            let scatterData = dataProvider.scatterData,
            let animator = animator,
            let viewPortHandler = self.viewPortHandler
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
                
                guard shouldDrawValues(forDataSet: dataSet),
                    let formatter = dataSet.valueFormatter
                    else { continue }

                let valueFont = dataSet.valueFont

                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                let shapeSize = dataSet.scatterShapeSize
                let lineHeight = valueFont.lineHeight
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                for j in _xBounds.min...(_xBounds.range + _xBounds.min)
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y) * phaseY
                    pt = pt.applying(valueToPixelMatrix)
                    
                    guard viewPortHandler.isInBoundsRight(pt.x) else { break }
                    
                    // make sure the lines don't do shitty things outside bounds
                    guard viewPortHandler.isInBoundsLeft(pt.x),
                        viewPortHandler.isInBoundsY(pt.y)
                        else { continue }
                    
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
                            attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
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
    
    open override func drawExtras(context: CGContext)
    {
        
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard let dataProvider = dataProvider,
            let scatterData = dataProvider.scatterData,
            let animator = animator
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }

        for high in indices
        {
            guard let set = scatterData.getDataSetByIndex(high.dataSetIndex) as? IScatterChartDataSet,
                set.isHighlightEnabled,
                let entry = set.entryForXValue(high.x, closestToY: high.y),
                isInBoundsX(entry: entry, dataSet: set)
                else { continue }

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
    }
}
