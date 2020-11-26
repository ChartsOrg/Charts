//
//  GearChartRenderer
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


open class GearChartRenderer: NSObject, DataRenderer
{
	public var accessibleChartElements: [NSUIAccessibilityElement] = []
	
	public var animator: Animator
	
	public func initBuffers() { }
	
	public var viewPortHandler: ViewPortHandler
	
	open weak var chart: GearChartView?
	
	public func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool {
		guard let data = dataProvider?.data else { return false }
		return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
	}
	
	public func createAccessibleHeader(usingChart chart: ChartViewBase, andData data: ChartData, withDefaultDescription defaultDescription: String) -> NSUIAccessibilityElement {
		return AccessibleHeader.create(usingChart: chart, andData: data, withDefaultDescription: defaultDescription)
	}
	
	@objc public init(chart: GearChartView, animator: Animator, viewPortHandler: ViewPortHandler)
	{
		self.viewPortHandler = viewPortHandler
		self.animator = animator
		self.chart = chart

		super.init()
	}
	
	open func drawData(context: CGContext)
	{
		guard let chart = chart else { return }
		
		let pieData = chart.data
		
		if pieData != nil
		{
			for set in pieData!.dataSets as! [GearChartDataSet]
			{
				if set.isVisible && set.entryCount > 0
				{
					drawDataSet(context: context, dataSet: set)
				}
			}
		}
	}
	
	open func calculateMinimumRadiusForSpacedSlice(
		center: CGPoint,
		radius: CGFloat,
		angle: CGFloat,
		arcStartPointX: CGFloat,
		arcStartPointY: CGFloat,
		startAngle: CGFloat,
		sweepAngle: CGFloat) -> CGFloat
	{
		let angleMiddle = startAngle + sweepAngle / 2.0
		
		// Other point of the arc
		let arcEndPointX = center.x + radius * cos((startAngle + sweepAngle).DEG2RAD)
		let arcEndPointY = center.y + radius * sin((startAngle + sweepAngle).DEG2RAD)
		
		// Middle point on the arc
		let arcMidPointX = center.x + radius * cos(angleMiddle.DEG2RAD)
		let arcMidPointY = center.y + radius * sin(angleMiddle.DEG2RAD)
		
		// This is the base of the contained triangle
		let basePointsDistance = sqrt(
			pow(arcEndPointX - arcStartPointX, 2) +
				pow(arcEndPointY - arcStartPointY, 2))
		
		// After reducing space from both sides of the "slice",
		//   the angle of the contained triangle should stay the same.
		// So let's find out the height of that triangle.
		let containedTriangleHeight = (basePointsDistance / 2.0 *
			tan(((180.0 - angle) / 2.0).DEG2RAD))
		
		// Now we subtract that from the radius
		var spacedRadius = radius - containedTriangleHeight
		
		// And now subtract the height of the arc that's between the triangle and the outer circle
		spacedRadius -= sqrt(
			pow(arcMidPointX - (arcEndPointX + arcStartPointX) / 2.0, 2) +
				pow(arcMidPointY - (arcEndPointY + arcStartPointY) / 2.0, 2))
		
		return spacedRadius
	}

	open func drawDataSet(context: CGContext, dataSet: GearChartDataSet)
	{
		guard
			let chart = chart
			else {return }
		
		let angle: CGFloat = 0.0
		let rotationAngle = chart.rotationAngle
		let phaseY = animator.phaseY
		
		let entryCount = dataSet.count
		let drawAngles = chart.drawAngles
		let center = chart.centerCircleBox
		let radius = chart.radius
		
		var visibleAngleCount = 0
		for j in 0 ..< entryCount
		{
			guard let e = dataSet.entryForIndex(j) else { continue }
			if ((abs(e.y) > .ulpOfOne))
			{
				visibleAngleCount += 1
			}
		}

		context.saveGState()
		
		let startAngleOuter = rotationAngle + angle * CGFloat(phaseY)
		let arcStartPointX = center.x + radius * cos(startAngleOuter.DEG2RAD)
		let arcStartPointY = center.y + radius * sin(startAngleOuter.DEG2RAD)
		
		//draw backgound circle
		let bgPath = CGMutablePath()
		bgPath.move(to: CGPoint(x: arcStartPointX, y: arcStartPointY))
		bgPath.addRelativeArc(center: center, radius: radius, startAngle: startAngleOuter.DEG2RAD, delta: CGFloat(360).DEG2RAD)
		
		context.beginPath()
		context.addPath(bgPath)
		
		let color = dataSet.bgGearColor
		context.setStrokeColor((color?.cgColor)!)
		context.setLineWidth(dataSet.gearLineWidth)
		context.strokePath()
		
		
		//draw percent gear
		let sliceAngle = drawAngles[0]
		let e = dataSet.entryForIndex(0)!
		
		// draw only if the value is greater than zero
		if (abs(e.y) > .ulpOfOne)
		{
			
			var sweepAngleOuter = (sliceAngle) * CGFloat(phaseY)
			if sweepAngleOuter < 0.0
			{
				sweepAngleOuter = 0.0
			}
			
			let path = CGMutablePath()
			path.move(to: CGPoint(x: arcStartPointX, y: arcStartPointY))
			path.addRelativeArc(center: center, radius: radius, startAngle: startAngleOuter.DEG2RAD, delta: sweepAngleOuter.DEG2RAD)
			
			context.beginPath()
			context.addPath(path)
			
			let color = dataSet.gearColor
			context.setStrokeColor((color?.cgColor)!)
			
			context.setLineCap(.round)
			context.setLineWidth(dataSet.gearLineWidth)
			context.strokePath()
			
		}
		
		context.restoreGState()
	}
	
	open func drawValues(context: CGContext)
	{
		guard
			let chart = chart,
			let data = chart.data
			else { return }
		
		let center = chart.centerCircleBox
		
		// get whole the radius
		let radius = chart.radius
		let rotationAngle = chart.rotationAngle
		let drawAngles = chart.drawAngles
		let absoluteAngles = chart.absoluteAngles
		
		let phaseX = animator.phaseX
		let phaseY = animator.phaseY
		
		let labelRadiusOffset = radius / 10.0 * 3.0
		let labelRadius = radius - labelRadiusOffset
		
		let dataSets = data.dataSets
		
		let drawEntryLabels = chart.isDrawEntryLabelsEnabled
		
		var angle: CGFloat = 0.0
		var xIndex = 0
		
		context.saveGState()
		defer { context.restoreGState() }
		
		
		let dataSet = dataSets[0] as! GearChartDataSet
		
		let drawValues = dataSet.isDrawValuesEnabled
		let iconsOffset = dataSet.iconsOffset
		
		let xValuePosition = dataSet.xValuePosition
		let yValuePosition = dataSet.yValuePosition
		
		let valueFont = dataSet.valueFont
		let lineHeight = valueFont.lineHeight
		
		let formatter = dataSet.valueFormatter
		
		for j in 0 ..< dataSet.entryCount
		{
			guard let e = dataSet.entryForIndex(j) else { continue }
			
			if xIndex == 0
			{
				angle = 0.0
			}
			else
			{
				angle = absoluteAngles[xIndex - 1] * CGFloat(phaseX)
			}
			
			let sliceAngle = drawAngles[xIndex]
			
			// offset needed to center the drawn text in the slice
			let angleOffset = (sliceAngle / 2.0) / 2.0
			
			angle = angle + angleOffset
			
			let transformedAngle = rotationAngle + angle * CGFloat(phaseY)
			
			let value = e.y
			let valueText = formatter.stringForValue(
				value,
				entry: e,
				dataSetIndex: 0,
				viewPortHandler: viewPortHandler)
			
			let sliceXBase = cos(transformedAngle.DEG2RAD)
			let sliceYBase = sin(transformedAngle.DEG2RAD)
			
			let drawXOutside = drawEntryLabels && xValuePosition == .outsideSlice
			let drawYOutside = drawValues && yValuePosition == .outsideSlice
			let drawXInside = drawEntryLabels && xValuePosition == .insideSlice
			let drawYInside = drawValues && yValuePosition == .insideSlice
			
			let valueTextColor = dataSet.valueTextColorAt(j)
			
			if drawXOutside || drawYOutside
			{
				let valueLineLength1 = dataSet.valueLinePart1Length
				let valueLineLength2 = dataSet.valueLinePart2Length
				let valueLinePart1OffsetPercentage = dataSet.valueLinePart1OffsetPercentage
				
				var pt2: CGPoint
				var labelPoint: CGPoint
				var align: NSTextAlignment
				
				var line1Radius: CGFloat
				line1Radius = radius * valueLinePart1OffsetPercentage
				
				
				let polyline2Length = dataSet.valueLineVariableLength
					? labelRadius * valueLineLength2 * abs(sin(transformedAngle.DEG2RAD))
					: labelRadius * valueLineLength2
				
				let pt0 = CGPoint(
					x: line1Radius * sliceXBase + center.x,
					y: line1Radius * sliceYBase + center.y)
				
				let pt1 = CGPoint(
					x: labelRadius * (1 + valueLineLength1) * sliceXBase + center.x,
					y: labelRadius * (1 + valueLineLength1) * sliceYBase + center.y)
				
				if transformedAngle.truncatingRemainder(dividingBy: 360.0) >= 90.0 && transformedAngle.truncatingRemainder(dividingBy: 360.0) <= 270.0
				{
					pt2 = CGPoint(x: pt1.x - polyline2Length, y: pt1.y)
					align = .right
					labelPoint = CGPoint(x: pt2.x - 5, y: pt2.y - lineHeight)
				}
				else
				{
					pt2 = CGPoint(x: pt1.x + polyline2Length, y: pt1.y)
					align = .left
					labelPoint = CGPoint(x: pt2.x + 5, y: pt2.y - lineHeight)
				}
				
				if dataSet.valueLineColor != nil
				{
					context.setStrokeColor(dataSet.valueLineColor!.cgColor)
					context.setLineWidth(dataSet.valueLineWidth)
					
					context.move(to: CGPoint(x: pt0.x, y: pt0.y))
					context.addLine(to: CGPoint(x: pt1.x, y: pt1.y))
					context.addLine(to: CGPoint(x: pt2.x, y: pt2.y))
					
					context.drawPath(using: CGPathDrawingMode.stroke)
				}
				
				if drawXOutside && drawYOutside
				{
					context.drawText(valueText, at: labelPoint, align: align, attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor])
				}
				else if drawYOutside
				{
					context.drawText(valueText, at: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight / 2.0), align: align, attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor])
				}
			}
			
			if drawXInside || drawYInside
			{
				// calculate the text position
				let x = labelRadius * sliceXBase + center.x
				let y = labelRadius * sliceYBase + center.y - lineHeight
				
				if drawXInside && drawYInside
				{
					context.drawText(valueText, at: CGPoint(x: x, y: y), align: .center, attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor])
				}
				else if drawYInside
				{
					context.drawText(valueText, at: CGPoint(x: x, y: y + lineHeight / 2.0), align: .center, attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor])
				}
			}
			
			if let icon = e.icon, dataSet.isDrawIconsEnabled
			{
				// calculate the icon's position
				
				let x = (labelRadius + iconsOffset.y) * sliceXBase + center.x
				var y = (labelRadius + iconsOffset.y) * sliceYBase + center.y
				y += iconsOffset.x
				
				context.drawImage(icon, atCenter: CGPoint(x: x, y: y), size: icon.size)
			}
			
			xIndex += 1
			
		}
	}
	
	open func drawExtras(context: CGContext)
	{
		drawCenterText(context: context)
	}
	
	
	
	/// draws the description text in the center of the pie chart makes most sense when center-hole is enabled
	fileprivate func drawCenterText(context: CGContext)
	{
		guard
			let chart = chart,
			let centerAttributedText = chart.centerAttributedText
			else { return }
		
		if chart.drawCenterTextEnabled && centerAttributedText.length > 0
		{
			let center = chart.centerCircleBox
			let offset = chart.centerTextOffset
			let innerRadius = chart.radius
			
			let x = center.x + offset.x
			let y = center.y + offset.y
			
			let holeRect = CGRect(
				x: x - innerRadius,
				y: y - innerRadius,
				width: innerRadius * 2.0,
				height: innerRadius * 2.0)
			var boundingRect = holeRect
			
			if chart.centerTextRadiusPercent > 0.0
			{
				boundingRect = boundingRect.insetBy(dx: (boundingRect.width - boundingRect.width * chart.centerTextRadiusPercent) / 2.0, dy: (boundingRect.height - boundingRect.height * chart.centerTextRadiusPercent) / 2.0)
			}
			
			let textBounds = centerAttributedText.boundingRect(with: boundingRect.size, options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], context: nil)
			
			var drawingRect = boundingRect
			drawingRect.origin.x += (boundingRect.size.width - textBounds.size.width) / 2.0
			drawingRect.origin.y += (boundingRect.size.height - textBounds.size.height) / 2.0
			drawingRect.size = textBounds.size
			
			context.saveGState()

			let clippingPath = CGPath(ellipseIn: holeRect, transform: nil)
			context.beginPath()
			context.addPath(clippingPath)
			context.clip()
			
			centerAttributedText.draw(with: drawingRect, options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], context: nil)
			
			context.restoreGState()
		}
	}
	
	open func drawHighlighted(context: CGContext, indices: [Highlight])
	{
		guard
			let chart = chart,
			let data = chart.data
			else { return }
		
		context.saveGState()
		
		let phaseX = animator.phaseX
		let phaseY = animator.phaseY
		
		var angle: CGFloat = 0.0
		let rotationAngle = chart.rotationAngle
		
		let drawAngles = chart.drawAngles
		let absoluteAngles = chart.absoluteAngles
		let center = chart.centerCircleBox
		let radius = chart.radius
		
		for i in 0 ..< indices.count
		{
			// get the index to highlight
			let index = Int(indices[i].x)
			if index >= drawAngles.count
			{
				continue
			}
			
			guard let set = data.dataSet(at: indices[i].dataSetIndex) as? GearChartDataSetProtocol else { continue }
			
			if !set.isHighlightEnabled
			{
				continue
			}

			let entryCount = set.entryCount
			var visibleAngleCount = 0
			for j in 0 ..< entryCount
			{
				guard let e = set.entryForIndex(j) else { continue }
				if ((abs(e.y) > Double.ulpOfOne))
				{
					visibleAngleCount += 1
				}
			}
			
			if index == 0
			{
				angle = 0.0
			}
			else
			{
				angle = absoluteAngles[index - 1] * CGFloat(phaseX)
			}
			
			let sliceAngle = drawAngles[index]
			
			let shift = set.selectionShift
			let highlightedRadius = radius + shift
			
			context.setFillColor(set.color(atIndex: index).cgColor)
			
			var sweepAngleOuter = (sliceAngle) * CGFloat(phaseY)
			if sweepAngleOuter < 0.0
			{
				sweepAngleOuter = 0.0
			}
			
			let startAngleShifted = rotationAngle + (angle / 2.0) * CGFloat(phaseY)
			var sweepAngleShifted = (sliceAngle) * CGFloat(phaseY)
			if sweepAngleShifted < 0.0
			{
				sweepAngleShifted = 0.0
			}
			
			let path = CGMutablePath()
			
			path.move(to: CGPoint(x: center.x + highlightedRadius * cos(startAngleShifted.DEG2RAD),
								  y: center.y + highlightedRadius * sin(startAngleShifted.DEG2RAD)))
			
			path.addRelativeArc(center: center, radius: highlightedRadius, startAngle: startAngleShifted.DEG2RAD,
								delta: sweepAngleShifted.DEG2RAD)
			
			context.beginPath()
			context.addPath(path)
			
			let color = set.colors[i]
			context.setStrokeColor(color.cgColor)
			
			context.setLineCap(.round)
			context.setLineWidth(20.0)
			context.strokePath()
		}
		
		context.restoreGState()
	}
}
