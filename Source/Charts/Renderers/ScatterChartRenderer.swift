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
    @objc open weak var dataProvider: ScatterChartDataProvider?
    
    @objc public init(dataProvider: ScatterChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        self.dataProvider = dataProvider

        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    open override func drawData(context: CGContext)
    {
        guard let scatterData = dataProvider?.scatterData else { return }
        
        for i in 0 ..< scatterData.dataSetCount
        {
            guard let set = scatterData.getDataSetByIndex(i) as? ScatterChartDataSetProtocol else
            {
                fatalError("Datasets for ScatterChartRenderer must conform to ScatterChartDataSetProtocol")
            }
            
            guard set.isVisible else { continue }

            drawDataSet(context: context, dataSet: set)
        }
    }

    @objc open func drawDataSet(context: CGContext, dataSet: ScatterChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        
        var point = CGPoint.zero
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if let renderer = dataSet.shapeRenderer
        {
            context.saveGState()
            defer { context.restoreGState() }

            for j in 0 ..< Int(min(ceil(Double(entryCount) * animator.phaseX), Double(entryCount)))
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                point.x = CGFloat(e.x)
                point.y = CGFloat(e.y * phaseY)
                point = point.applying(valueToPixelMatrix)
                
                guard viewPortHandler.isInBoundsRight(point.x) else { break }

                guard
                    viewPortHandler.isInBoundsLeft(point.x),
                    viewPortHandler.isInBoundsY(point.y)
                    else { continue }

                renderer.renderShape(context: context, dataSet: dataSet, viewPortHandler: viewPortHandler, point: point, color: dataSet.color(atIndex: j))
            }
        }
        else
        {
            print("There's no ShapeRenderer specified for ScatterDataSet", terminator: "\n")
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let scatterData = dataProvider.scatterData,
            isDrawingValuesAllowed(dataProvider: dataProvider)
            else { return }
        
        // if values are drawn
        guard let dataSets = scatterData.dataSets as? [ScatterChartDataSetProtocol] else { return }

        let phaseY = animator.phaseY

        var pt = CGPoint.zero

        for i in 0 ..< scatterData.dataSetCount
        {
            let dataSet = dataSets[i]

            guard
                shouldDrawValues(forDataSet: dataSet),
                let formatter = dataSet.valueFormatter
                else { continue }

            let valueFont = dataSet.valueFont

            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix

            let iconsOffset = dataSet.iconsOffset

            let shapeSize = dataSet.scatterShapeSize
            let lineHeight = valueFont.lineHeight

            xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)

            for j in xBounds.min...(xBounds.range + xBounds.min)
            {
                guard let e = dataSet.entryForIndex(j) else { break }

                pt.x = CGFloat(e.x)
                pt.y = CGFloat(e.y * phaseY)
                pt = pt.applying(valueToPixelMatrix)

                guard viewPortHandler.isInBoundsRight(pt.x) else { break }

                // make sure the lines don't do shitty things outside bounds
                guard
                    viewPortHandler.isInBoundsLeft(pt.x),
                    viewPortHandler.isInBoundsY(pt.y)
                    else { continue }

                let text = formatter.stringForValue(e.y,
                                                    entry: e,
                                                    dataSetIndex: i,
                                                    viewPortHandler: viewPortHandler)

                if dataSet.isDrawValuesEnabled
                {
                    context.drawText(text,
                                     at: CGPoint(x: pt.x,
                                                 y: pt.y - shapeSize - lineHeight),
                                     align: .center,
                                     attributes: [.font: valueFont,
                                                  .foregroundColor: dataSet.valueTextColorAt(j)])
                }

                if let icon = e.icon, dataSet.isDrawIconsEnabled
                {
                    context.drawImage(icon,
                                      atCenter: CGPoint(x: pt.x + iconsOffset.x,
                                                        y: pt.y + iconsOffset.y),
                                      size: icon.size)
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext) { }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let scatterData = dataProvider.scatterData
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }

        for high in indices
        {
            guard
                let set = scatterData.getDataSetByIndex(high.dataSetIndex) as? ScatterChartDataSetProtocol,
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
