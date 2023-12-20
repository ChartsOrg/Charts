//
//  LineChartMaxMinValueRenderer.swift
//  DGCharts
//
//  Created by Joy BIAN on 2023/12/4.
//

import UIKit

open class LineChartMaxMinValueRenderer: LineChartRenderer {
    
//    private lazy var accessibilityOrderedElements: [[NSUIAccessibilityElement]] = accessibilityCreateEmptyOrderedElements()

    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData
        else { return }

        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in lineData.indices
            {
                guard let
                        dataSet = lineData[i] as? LineChartMaxMinDataSet,
                      shouldDrawValues(forDataSet: dataSet)
                else { continue }
                
                let valueFont = dataSet.valueFont
                
                let formatter = dataSet.valueFormatter
                
                let angleRadians = dataSet.valueLabelAngle.DEG2RAD
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75)
                
                if !dataSet.isDrawCirclesEnabled
                {
                    valOffset = valOffset / 2
                }
                valOffset += 1
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                for j in _xBounds
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    if dataSet.isDrawValuesEnabled
                    {
                        context.drawText(formatter.stringForValue(e.y,
                                                                  entry: e,
                                                                  dataSetIndex: i,
                                                                  viewPortHandler: viewPortHandler),
                                         at: CGPoint(x: pt.x,
                                                     y: pt.y - CGFloat(valOffset) - valueFont.lineHeight),
                                         align: .center,
                                         angleRadians: angleRadians,
                                         attributes: [.font: valueFont,
                                                      .foregroundColor: dataSet.valueTextColorAt(j)])
                    } else if dataSet.isDrawMaxMinValueEnabled {
                        if Int(e.x) == dataSet.maxValueIndex {
                            let valueText = formatter.stringForValue(e.y, entry: e, dataSetIndex: i, viewPortHandler: viewPortHandler)
                            let w = valueText.widthWithConstrainedHeight(font: valueFont) + 4
                            let path = UIBezierPath(roundedRect: CGRect(x: pt.x - w * 0.5, y: pt.y - CGFloat(valOffset) - valueFont.lineHeight - (16 - valueFont.lineHeight) * 0.5, width: w, height: 16), cornerRadius: 2)
                            context.setFillColor(dataSet.color(atIndex: j).cgColor)
                            context.addPath(path.cgPath)
                            context.fillPath()
                            
                            context.drawText(valueText, at: CGPoint(x: pt.x, y: pt.y - CGFloat(valOffset) - valueFont.lineHeight), align: .center, angleRadians: angleRadians, attributes: [.font: valueFont, .foregroundColor: dataSet.valueTextColorAt(j)])
                        } else if Int(e.x) == dataSet.minValueIndex {
                            let valueText = formatter.stringForValue(e.y, entry: e, dataSetIndex: i, viewPortHandler: viewPortHandler)
                            let w = valueText.widthWithConstrainedHeight(font: valueFont) + 4
                            let path = UIBezierPath(roundedRect: CGRect(x: pt.x - w * 0.5, y: pt.y + CGFloat(valOffset) - (16 - valueFont.lineHeight) * 0.5, width: w, height: 16), cornerRadius: 2)
                            context.setFillColor(dataSet.color(atIndex: j).cgColor)
                            context.addPath(path.cgPath)
                            context.fillPath()
                            
                            context.drawText(valueText, at: CGPoint(x: pt.x, y: pt.y + CGFloat(valOffset)), align: .center, angleRadians: angleRadians, attributes: [.font: valueFont, .foregroundColor: dataSet.valueTextColorAt(j)])
                        }
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
    }
    
//    open override func drawExtras(context: CGContext)
//    {
//        drawCircles(context: context)
//    }
//
//    private func drawCircles(context: CGContext)
//    {
//        guard
//            let dataProvider = dataProvider,
//            let lineData = dataProvider.lineData
//        else { return }
//
//        let phaseY = animator.phaseY
//
//        var pt = CGPoint()
//        var rect = CGRect()
//
//        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
//        accessibleChartElements.removeAll()
//        accessibilityOrderedElements = accessibilityCreateEmptyOrderedElements()
//
//        // Make the chart header the first element in the accessible elements array
//        if let chart = dataProvider as? LineChartView {
//            let element = createAccessibleHeader(usingChart: chart,
//                                                 andData: lineData,
//                                                 withDefaultDescription: "Line Chart")
//            accessibleChartElements.append(element)
//        }
//
//        context.saveGState()
//
//        for i in lineData.indices
//        {
//            guard let dataSet = lineData[i] as? LineChartMaxMinDataSet else { continue }
//
//            // Skip Circles and Accessibility if not enabled,
//            // reduces CPU significantly if not needed
//            if !dataSet.isVisible || !dataSet.isDrawCirclesEnabled || dataSet.entryCount == 0
//            {
//                continue
//            }
//
//            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
//            let valueToPixelMatrix = trans.valueToPixelMatrix
//
//            _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
//
//            let circleRadius = dataSet.circleRadius
//            let circleDiameter = circleRadius * 2.0
//            let circleHoleRadius = dataSet.circleHoleRadius
//            let circleHoleDiameter = circleHoleRadius * 2.0
//
//            let drawCircleHole = dataSet.isDrawCircleHoleEnabled &&
//                circleHoleRadius < circleRadius &&
//                circleHoleRadius > 0.0
//            let drawTransparentCircleHole = drawCircleHole &&
//                (dataSet.circleHoleColor == nil ||
//                    dataSet.circleHoleColor == NSUIColor.clear)
//
//            for j in _xBounds
//            {
//                guard let e = dataSet.entryForIndex(j) else { break }
//
//                pt.x = CGFloat(e.x)
//                pt.y = CGFloat(e.y * phaseY)
//                pt = pt.applying(valueToPixelMatrix)
//
//                if (!viewPortHandler.isInBoundsRight(pt.x))
//                {
//                    break
//                }
//
//                // make sure the circles don't do shitty things outside bounds
//                if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
//                {
//                    continue
//                }
//
//                if dataSet
//                    .isDrawMaxMinValueEnabled {
//                    if Int(e.x) != dataSet.maxValueIndex && Int(e.x) != dataSet.minValueIndex {
//                        continue
//                    }
//                }
//
//                // Accessibility element geometry
//                let scaleFactor: CGFloat = 3
//                let accessibilityRect = CGRect(x: pt.x - (scaleFactor * circleRadius),
//                                               y: pt.y - (scaleFactor * circleRadius),
//                                               width: scaleFactor * circleDiameter,
//                                               height: scaleFactor * circleDiameter)
//                // Create and append the corresponding accessibility element to accessibilityOrderedElements
//                if let chart = dataProvider as? LineChartView
//                {
//                    let element = createAccessibleElement(withIndex: j,
//                                                          container: chart,
//                                                          dataSet: dataSet,
//                                                          dataSetIndex: i)
//                    { (element) in
//                        element.accessibilityFrame = accessibilityRect
//                    }
//
//                    accessibilityOrderedElements[i].append(element)
//                }
//
//                context.setFillColor(dataSet.getCircleColor(atIndex: j)!.cgColor)
//
//                rect.origin.x = pt.x - circleRadius
//                rect.origin.y = pt.y - circleRadius
//                rect.size.width = circleDiameter
//                rect.size.height = circleDiameter
//
//                if drawTransparentCircleHole
//                {
//                    // Begin path for circle with hole
//                    context.beginPath()
//                    context.addEllipse(in: rect)
//
//                    // Cut hole in path
//                    rect.origin.x = pt.x - circleHoleRadius
//                    rect.origin.y = pt.y - circleHoleRadius
//                    rect.size.width = circleHoleDiameter
//                    rect.size.height = circleHoleDiameter
//                    context.addEllipse(in: rect)
//
//                    // Fill in-between
//                    context.fillPath(using: .evenOdd)
//                }
//                else
//                {
//                    context.fillEllipse(in: rect)
//
//                    if drawCircleHole
//                    {
//                        context.setFillColor(dataSet.circleHoleColor!.cgColor)
//
//                        // The hole rect
//                        rect.origin.x = pt.x - circleHoleRadius
//                        rect.origin.y = pt.y - circleHoleRadius
//                        rect.size.width = circleHoleDiameter
//                        rect.size.height = circleHoleDiameter
//
//                        context.fillEllipse(in: rect)
//                    }
//                }
//            }
//        }
//
//        context.restoreGState()
//
//        // Merge nested ordered arrays into the single accessibleChartElements.
//        accessibleChartElements.append(contentsOf: accessibilityOrderedElements.flatMap { $0 } )
//        accessibilityPostLayoutChangedNotification()
//    }
//
//    /// Creates a nested array of empty subarrays each of which will be populated with NSUIAccessibilityElements.
//    /// This is marked internal to support HorizontalBarChartRenderer as well.
//    private func accessibilityCreateEmptyOrderedElements() -> [[NSUIAccessibilityElement]]
//    {
//        guard let chart = dataProvider as? LineChartView else { return [] }
//
//        let dataSetCount = chart.lineData?.dataSetCount ?? 0
//
//        return Array(repeating: [NSUIAccessibilityElement](),
//                     count: dataSetCount)
//    }
//
//    /// Creates an NSUIAccessibleElement representing the smallest meaningful bar of the chart
//    /// i.e. in case of a stacked chart, this returns each stack, not the combined bar.
//    /// Note that it is marked internal to support subclass modification in the HorizontalBarChart.
//    private func createAccessibleElement(withIndex idx: Int,
//                                         container: LineChartView,
//                                         dataSet: LineChartDataSetProtocol,
//                                         dataSetIndex: Int,
//                                         modifier: (NSUIAccessibilityElement) -> ()) -> NSUIAccessibilityElement
//    {
//        let element = NSUIAccessibilityElement(accessibilityContainer: container)
//        let xAxis = container.xAxis
//
//        guard let e = dataSet.entryForIndex(idx) else { return element }
//        guard let dataProvider = dataProvider else { return element }
//
//        // NOTE: The formatter can cause issues when the x-axis labels are consecutive ints.
//        // i.e. due to the Double conversion, if there are more than one data set that are grouped,
//        // there is the possibility of some labels being rounded up. A floor() might fix this, but seems to be a brute force solution.
//        let label = xAxis.valueFormatter?.stringForValue(e.x, axis: xAxis) ?? "\(e.x)"
//
//        let elementValueText = dataSet.valueFormatter.stringForValue(e.y,
//                                                                     entry: e,
//                                                                     dataSetIndex: dataSetIndex,
//                                                                     viewPortHandler: viewPortHandler)
//
//        let dataSetCount = dataProvider.lineData?.dataSetCount ?? -1
//        let doesContainMultipleDataSets = dataSetCount > 1
//
//        element.accessibilityLabel = "\(doesContainMultipleDataSets ? (dataSet.label ?? "")  + ", " : "") \(label): \(elementValueText)"
//
//        modifier(element)
//
//        return element
//    }
}

extension String {
    /// 高度固定, 获取文本宽度
    func widthWithConstrainedHeight(height: CGFloat = CGFloat.greatestFiniteMagnitude, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingRect = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil)
        return boundingRect.width
    }
}
