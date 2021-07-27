//
//  CustomDrawChartRenderer.swift
//  Charts
//
//  Created by JustLee on 2021/7/22.
//

import Foundation
import CoreGraphics

open class CustomDrawChartRenderer: BarLineScatterCandleBubbleRenderer {
    
    @objc open weak var dataProvider: BarLineScatterCandleBubbleChartDataProvider?
    
    @objc public init(dataProvider: BarLineScatterCandleBubbleChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext) {
        guard let customDrawData = dataProvider?.customDrawData else { return }
        
        for i in 0 ..< customDrawData.dataSetCount
        {
            guard let set = customDrawData.dataSet(at: i) as? CustomDrawChartDataSet else {
                fatalError("Datasets for CustomDrawRenderer must inherit with CustomDrawChartDataSet")
                continue
            }
            
            if set.isVisible
            {
                drawCustomDataSet(context: context, dataSet: set)
            }
        }

    }
    
    open func drawCustomDataSet(context: CGContext, dataSet: CustomDrawChartDataSet)
    {
        dataSet.clearGraphicsPath()
        
        switch dataSet.customDrawLineType {
        case .lineSegment:
            drawLineSegment(context: context, dataSet: dataSet)
            break
            
        case .threeWaves:
            drawLineWaves(context: context, dataSet: dataSet)
            break
            
        case .rectangle:
            drawClosedGraphics(context: context, dataSet: dataSet)
            break

        case .fibonacciPeriod:
            drawFibonacciPeriodLine(context: context, dataSet: dataSet)
            break
            
        case .lineHorizontal:
            drawHorizontalLine(context: context, dataSet: dataSet)
            break
        }
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard let customDrawData = dataProvider?.customDrawData else { return }
        
        for high in indices {
            
            guard let dataSet = customDrawData[high.dataSetIndex] as? CustomDrawChartDataSet,
                   dataSet.isHighlightEnabled else { continue }
            
            if dataSet.customDrawLineType.calculatePathType != .closedGraphics
            {
                drawBaseAlphaPath(context: context, dataSet: dataSet)
            }
            
            dataSet.forEach {
                drawBaseCircle(context: context, dataSet: dataSet, beginEntry: $0)
            }
        }
    }
}

///graphics type function
extension CustomDrawChartRenderer {
    
    open func drawLineSegment(context: CGContext, dataSet: CustomDrawChartDataSet)
    {
        if dataSet.finished
        {
            drawBaseContinuousLineSegment(context: context, dataSet: dataSet)
        } else {
            dataSet.forEach {
                drawBaseCircle(context: context, dataSet: dataSet, beginEntry: $0)
            }
        }
    }

    open func drawLineWaves(context: CGContext, dataSet: CustomDrawChartDataSet) {
        if dataSet.count == 1, let entry = dataSet.first
        {
            drawBaseCircle(context: context, dataSet: dataSet, beginEntry: entry)
        } else {
            drawBaseContinuousLineSegment(context: context, dataSet: dataSet)
        }
    }
    
    open func drawClosedGraphics(context: CGContext, dataSet: CustomDrawChartDataSet)
    {
        if dataSet.finished
        {
            drawBaseClosedGraphics(context: context, dataSet: dataSet)
        } else {
            dataSet.entries.forEach {
                drawBaseCircle(context: context, dataSet: dataSet, beginEntry: $0)
            }
        }
    }
    
    open func drawFibonacciPeriodLine(context: CGContext, dataSet: CustomDrawChartDataSet)
    {
        guard let dataProvider = self.dataProvider else { return }

        dataSet.forEach {
            $0.y = Double.middleMagnitude(dataProvider.chartYMax, dataProvider.chartYMin)
        }
        
        if dataSet.finished {
            drawBaseContinuousLineSegment(context: context, dataSet: dataSet)
            FibonacciPeriod.getFibonacciSequenceBy(begin: dataSet.first!.x, next: dataSet.last!.x, count: 11).map {
                return CustomDrawChartDataEntry(x: $0, y: dataSet.first!.y)
            }.forEach {
                drawBaseLineVertical(context: context, dataSet: dataSet, beginEntry: $0)
            }
        } else {
            dataSet.entries.forEach {
                drawBaseLineVertical(context: context, dataSet: dataSet, beginEntry: $0)
            }
        }
    }
    
    open func drawHorizontalLine(context: CGContext, dataSet: CustomDrawChartDataSet)
    {
        guard let dataProvider = self.dataProvider else { return }

        if dataSet.finished
        {
            let entry = dataSet[0]
            entry.x = Double.middleMagnitude(dataProvider.chartXMin, dataProvider.chartXMax)
            
            drawBaseLineHorizontal(context: context, dataSet: dataSet, beginEntry: entry)
        }
    }
}

/// basic graphics function
extension CustomDrawChartRenderer {
    
    /// transform the entry to drawing point
    /// - Parameters:
    ///   - entry: entry description
    ///   - axisDependency: axisDependency description
    open func transformEntryToPixelPoint(entry: ChartDataEntry?, axisDependency: YAxis.AxisDependency = .left) -> CGPoint
    {
        guard let dataProvider = dataProvider,
              let entry = entry else { return .zero }
        
        let transformer = dataProvider.getTransformer(forAxis: axisDependency)
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        let phaseY = animator.phaseY
        
        return CGPoint(x: entry.x, y: entry.y * phaseY).applying(valueToPixelMatrix)
    }
    
    /// draw the point circle
    /// - Parameters:
    ///   - context: context description
    ///   - dataSet: dataSet description
    ///   - beginEntry: beginEntry
    open func drawBaseCircle(context: CGContext, dataSet: CustomDrawChartDataSet, beginEntry: ChartDataEntry)
    {
        let holdRadius = max(dataSet.circleHoleRadius, dataSet.lineWidth + 2)
        let circleRadius = dataSet.circleRadius
        
        let point = transformEntryToPixelPoint(entry: beginEntry, axisDependency: dataSet.axisDependency)
        let pointRect = CGRect(x: point.x - holdRadius, y: point.y - holdRadius, width: holdRadius * 2, height: holdRadius * 2)
        let circleRect = CGRect(x: point.x - circleRadius, y: point.y - circleRadius, width: circleRadius * 2, height: circleRadius * 2)

        context.setFillColor(dataSet.customDrawLineColor.withAlphaComponent(0.25).cgColor)
        context.fillEllipse(in: circleRect)
        
        context.setFillColor(dataSet.customDrawLineColor.cgColor)
        context.fillEllipse(in: pointRect)
    }
    
    /// draw the path for graphics
    /// - Parameters:
    ///   - context: context description
    ///   - dataSet: dataSet description
    open func drawBaseAlphaPath(context: CGContext, dataSet: CustomDrawChartDataSet)
    {
        context.setFillColor(dataSet.customDrawLineColor.withAlphaComponent(0.05).cgColor)
        dataSet.customDrawLinePaths.forEach {
            context.addPath($0.cgPath)
            context.drawPath(using: .fill)
        }
    }
    
    /// draw line segment with specific points
    /// - Parameters:
    ///   - context: context description
    ///   - dataSet: dataSet description
    ///   - beginEntry: beginEntry
    ///   - endEntry: endEntry
    open func drawBaseSpecificLineSegment(context: CGContext, dataSet: CustomDrawChartDataSet, beginEntry: ChartDataEntry, endEntry: ChartDataEntry)
    {
        context.setLineWidth(dataSet.lineWidth)
        if dataSet.lineDashLengths != nil {
            context.setLineDash(phase: dataSet.lineDashPhase, lengths: dataSet.lineDashLengths!)
        } else {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        context.setStrokeColor(dataSet.customDrawLineColor.cgColor)
        
        let beginPoint = transformEntryToPixelPoint(entry: beginEntry, axisDependency: dataSet.axisDependency)
        let endPoint = transformEntryToPixelPoint(entry: endEntry, axisDependency: dataSet.axisDependency)
        context.addLines(between: [beginPoint, endPoint])
        
        context.strokePath()
    
        dataSet.appendSingleLinePath(points: [beginPoint, endPoint])
    }
    
    /// draw continuous line segment
    /// - Parameters:
    ///   - context: context description
    ///   - dataSet: dataSet description
    open func drawBaseContinuousLineSegment(context: CGContext, dataSet: CustomDrawChartDataSet)
    {
        context.setLineWidth(dataSet.lineWidth)
        
        if dataSet.lineDashLengths != nil {
            context.setLineDash(phase: dataSet.lineDashPhase, lengths: dataSet.lineDashLengths!)
        } else {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        context.setStrokeColor(dataSet.customDrawLineColor.cgColor)
        
        for index in stride(from: 0, to: dataSet.entries.count - 1, by: 1) {
            let beginPoint = transformEntryToPixelPoint(entry: dataSet[index], axisDependency: dataSet.axisDependency)
            let endPoint = transformEntryToPixelPoint(entry: dataSet[index + 1], axisDependency: dataSet.axisDependency)
            context.addLines(between: [beginPoint, endPoint])
            context.strokePath()
            dataSet.appendSingleLinePath(points: [beginPoint, endPoint])
        }
    }
    
    /// draw closed graphics
    /// - Parameters:
    ///   - context: context description
    ///   - dataSet: dataSet description
    ///   - entries: entries description
    open func drawBaseClosedGraphics(context: CGContext, dataSet: CustomDrawChartDataSet)
    {
        context.setFillColor(dataSet.customDrawLineColor.withAlphaComponent(0.4).cgColor)
        
        var points = [CGPoint]()
        
        let firstPoint = transformEntryToPixelPoint(entry: dataSet.entries.first, axisDependency: dataSet.axisDependency)
        context.move(to: firstPoint)
        
        points.append(firstPoint)
        dataSet.entries.forEach {
            let transformPoint = transformEntryToPixelPoint(entry: $0, axisDependency: dataSet.axisDependency)
            points.append(transformPoint)
            context.addLine(to: transformPoint)
        }
        
        context.closePath()
        context.fillPath()
        
        dataSet.appendClosedGraphicsPath(points: points)
    }

    /// draw basic vertical line
    /// - Parameters:
    ///   - context: context description
    ///   - dataSet: dataSet description
    ///   - beginEntry: beginEntry description
    open func drawBaseLineVertical(context: CGContext, dataSet: CustomDrawChartDataSet, beginEntry: ChartDataEntry)
    {
        guard let dataProvider = self.dataProvider else { return }
        
        drawBaseSpecificLineSegment(context: context, dataSet: dataSet, beginEntry: ChartDataEntry(x: beginEntry.x, y: dataProvider.chartYMin), endEntry: ChartDataEntry(x: beginEntry.x, y: dataProvider.chartYMax))
    }
    
    /// draw basic horizontal line
    /// - Parameters:
    ///   - context: context description
    ///   - dataSet: dataSet description
    ///   - beginEntry: beginEntry
    open func drawBaseLineHorizontal(context: CGContext, dataSet: CustomDrawChartDataSet, beginEntry: ChartDataEntry)
    {
        guard let dataProvider = self.dataProvider else { return }
        
        drawBaseSpecificLineSegment(context: context, dataSet: dataSet, beginEntry: ChartDataEntry(x: dataProvider.chartXMin, y: beginEntry.y), endEntry: ChartDataEntry(x: dataProvider.chartXMax, y: beginEntry.y))
    }
}
