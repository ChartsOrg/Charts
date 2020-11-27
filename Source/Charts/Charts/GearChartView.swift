//
//  GearChartView
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

/// View that represents a pie chart. Draws cake like slices.
open class GearChartView: PieRadarChartViewBase
{
	/// rect object that represents the bounds of the gearchart, needed for drawing the circle
	fileprivate var _circleBox = CGRect()
	
	/// flag indicating if entry labels should be drawn or not
	fileprivate var _drawEntryLabelsEnabled = true
	
	/// array that holds the width of each pie-slice in degrees
	fileprivate var _drawAngles = [CGFloat]()
	
	/// array that holds the absolute angle in degrees of each slice
	fileprivate var _absoluteAngles = [CGFloat]()
	
	/// Sets the color the entry labels are drawn with.
	fileprivate var _entryLabelColor: NSUIColor? = NSUIColor.white
	
	/// Sets the font the entry labels are drawn with.
	fileprivate var _entryLabelFont: NSUIFont? = NSUIFont(name: "HelveticaNeue", size: 26.0)
	
	/// if true, the values inside the gearchart are drawn as percent values
	fileprivate var _usePercentValuesEnabled = false
	
	/// variable for the text that is drawn in the center of the pie-chart
	fileprivate var _centerAttributedText: NSAttributedString?
	
	/// the offset on the x- and y-axis the center text has in dp.
	fileprivate var _centerTextOffset: CGPoint = CGPoint()
	
	/// if enabled, centertext is drawn
	fileprivate var _drawCenterTextEnabled = true
	
	fileprivate var _centerTextRadiusPercent: CGFloat = 1.0
	
	/// maximum angle for this gear
	fileprivate var _maxAngle: CGFloat = 360.0
	
	/// background color for gear
	fileprivate var _gearBgColor: UIColor = UIColor.lightGray

	public override init(frame: CGRect)
	{
		super.init(frame: frame)
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
	
	internal override func initialize()
	{
		super.initialize()
		
		renderer = GearChartRenderer(chart: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
		
		self.highlighter = PieHighlighter(chart: self)
	}
	
	open override func draw(_ rect: CGRect)
	{
		super.draw(rect)
		
		if data === nil
		{
			return
		}
		
		let optionalContext = NSUIGraphicsGetCurrentContext()
		guard let context = optionalContext else { return }
		
		renderer!.drawData(context: context)
		
		if (valuesToHighlight())
		{
			renderer!.drawHighlighted(context: context, indices: highlighted)
		}
		
		renderer!.drawExtras(context: context)
		
		renderer!.drawValues(context: context)
		
		legendRenderer.renderLegend(context: context)
		
		drawDescription(in: context)
		
		drawMarkers(context: context)
	}
	
	internal override func calculateOffsets()
	{
		super.calculateOffsets()
		
		// prevent nullpointer when no data set
		if data === nil
		{
			return
		}
		
		let radius = diameter / 2.0
		
		let c = self.centerOffsets
		
		let shift = ((data as? GearChartData)?.dataSets.first as? GearChartDataSet)?.selectionShift ?? 0.0
		
		// create the circle box that will contain the pie-chart (the bounds of the pie-chart)
		_circleBox.origin.x = (c.x - radius) + shift
		_circleBox.origin.y = (c.y - radius) + shift
		_circleBox.size.width = diameter - shift * 2.0
		_circleBox.size.height = diameter - shift * 2.0
	}
	
	internal override func calcMinMax()
	{
		calcAngles()
	}
	
	open override func getMarkerPosition(highlight: Highlight) -> CGPoint
	{
		let center = self.centerCircleBox
		var r = self.radius
		
		let off = r / 10.0 * 3.6
		r -= off // offset to keep things inside the chart
		
		let rotationAngle = self.rotationAngle
		
		let entryIndex = Int(highlight.x)
		
		// offset needed to center the drawn text in the slice
		let offset = drawAngles[entryIndex] / 2.0
		
		// calculate the text position
		let x: CGFloat = (r * cos(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(chartAnimator.phaseY)).DEG2RAD) + center.x)
		let y: CGFloat = (r * sin(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(chartAnimator.phaseY)).DEG2RAD) + center.y)
		
		return CGPoint(x: x, y: y)
	}
	
	/// calculates the needed angles for the chart slices
	fileprivate func calcAngles()
	{
		_drawAngles = [CGFloat]()
		_absoluteAngles = [CGFloat]()
		
		guard let data = data else { return }

		let entryCount = data.entryCount
		
		_drawAngles.reserveCapacity(entryCount)
		_absoluteAngles.reserveCapacity(entryCount)
		
		let dataSets = data.dataSets

		var cnt = 0

		for i in 0 ..< data.dataSetCount
		{
			let set = dataSets[i]
			let entryCount = set.entryCount

			for j in 0 ..< entryCount
			{
				guard let e = set.entryForIndex(j) else { continue }
				
				_drawAngles.append(calcAngle(value: abs(e.y)))

				if cnt == 0
				{
					_absoluteAngles.append(_drawAngles[cnt])
				}
				else
				{
					_absoluteAngles.append(_absoluteAngles[cnt - 1] + _drawAngles[cnt])
				}

				cnt += 1
			}
		}
	}
	
	/// Checks if the given index is set to be highlighted.
	open func needsHighlight(index: Int) -> Bool
	{
		return highlighted.contains { Int($0.x) == index }
	}
	
	/// calculates the needed angle for a given value
	fileprivate func calcAngle(_ value: Double) -> CGFloat
	{
		return calcAngle(value: value)
	}
	
	/// calculates the needed angle for a given value
	fileprivate func calcAngle(value: Double) -> CGFloat
	{
		return CGFloat(value) / 100 * _maxAngle
	}
	
	/// This will throw an exception, PieChart has no XAxis object.
	open override var xAxis: XAxis
	{
		get { fatalError("PieChart has no XAxis") }
		set { fatalError("PieChart has no XAxis") }
	}
	
	open override func indexForAngle(_ angle: CGFloat) -> Int
	{
		// take the current angle of the chart into consideration
		let a = (angle - self.rotationAngle).normalizedAngle
		return _absoluteAngles.firstIndex { $0 > a } ?? -1
	}
	
	/// - returns: The index of the DataSet this x-index belongs to.
	open func dataSetIndexForIndex(_ xValue: Double) -> Int
	{
		// TODO: Return nil instead of -1
		return data?.firstIndex {
			$0.entryForXValue(xValue, closestToY: .nan) != nil
		} ?? -1
	}
	
	/// - returns: An integer array of all the different angles the chart slices
	/// have the angles in the returned array determine how much space (of 360°)
	/// each slice takes
	open var drawAngles: [CGFloat]
	{
		return _drawAngles
	}

	/// - returns: The absolute angles of the different chart slices (where the
	/// slices end)
	open var absoluteAngles: [CGFloat]
	{
		return _absoluteAngles
	}
	
	/// the text that is displayed in the center of the pie-chart
	open var centerText: String?
	{
		get
		{
			return self.centerAttributedText?.string
		}
		set
		{
			var attrString: NSMutableAttributedString?
			if newValue == nil
			{
				attrString = nil
			}
			else
			{
				#if os(OSX)
					let paragraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
				#else
					let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
				#endif
				paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
				paragraphStyle.alignment = .center
				
				attrString = NSMutableAttributedString(string: newValue!)
				attrString?.setAttributes([
					NSAttributedString.Key.foregroundColor: NSUIColor.black,
					NSAttributedString.Key.font: NSUIFont.systemFont(ofSize: 12.0),
					NSAttributedString.Key.paragraphStyle: paragraphStyle
					], range: NSMakeRange(0, attrString!.length))
			}
			self.centerAttributedText = attrString
		}
	}
	
	/// the text that is displayed in the center of the pie-chart
	@objc open var centerAttributedText: NSAttributedString?
	{
		get
		{
			return _centerAttributedText
		}
		set
		{
			_centerAttributedText = newValue
			setNeedsDisplay()
		}
	}
	
	/// Sets the offset the center text should have from it's original position in dp. Default x = 0, y = 0
	open var centerTextOffset: CGPoint
	{
		get
		{
			return _centerTextOffset
		}
		set
		{
			_centerTextOffset = newValue
			setNeedsDisplay()
		}
	}
	
	/// `true` if drawing the center text is enabled
	@objc open var drawCenterTextEnabled: Bool
	{
		get
		{
			return _drawCenterTextEnabled
		}
		set
		{
			_drawCenterTextEnabled = newValue
			setNeedsDisplay()
		}
	}
	
	/// - returns: `true` if drawing the center text is enabled
	open var isDrawCenterTextEnabled: Bool
	{
		get
		{
			return drawCenterTextEnabled
		}
	}
	
	internal override var requiredLegendOffset: CGFloat
	{
		return legend.font.pointSize * 2.0
	}
	
	internal override var requiredBaseOffset: CGFloat
	{
		return 0.0
	}
	
	open override var radius: CGFloat
	{
		return _circleBox.width / 2.0
	}
	
	/// - returns: The circlebox, the boundingbox of the pie-chart slices
	open var circleBox: CGRect
	{
		return _circleBox
	}
	
	/// - returns: The center of the circlebox
	open var centerCircleBox: CGPoint
	{
		return CGPoint(x: _circleBox.midX, y: _circleBox.midY)
	}
	
	/// set this to true to draw the enrty labels into the pie slices
	@available(*, deprecated: 1.0, message: "Use `drawEntryLabelsEnabled` instead.")
	open var drawSliceTextEnabled: Bool
	{
		get
		{
			return drawEntryLabelsEnabled
		}
		set
		{
			drawEntryLabelsEnabled = newValue
		}
	}
	
	/// - returns: `true` if drawing entry labels is enabled, `false` ifnot
	@available(*, deprecated: 1.0, message: "Use `isDrawEntryLabelsEnabled` instead.")
	open var isDrawSliceTextEnabled: Bool
	{
		get
		{
			return isDrawEntryLabelsEnabled
		}
	}
	
	/// The color the entry labels are drawn with.
	@objc open var entryLabelColor: NSUIColor?
	{
		get { return _entryLabelColor }
		set
		{
			_entryLabelColor = newValue
			setNeedsDisplay()
		}
	}
	
	/// The font the entry labels are drawn with.
	@objc open var entryLabelFont: NSUIFont?
	{
		get { return _entryLabelFont }
		set
		{
			_entryLabelFont = newValue
			setNeedsDisplay()
		}
	}
	
	/// Set this to true to draw the enrty labels into the pie slices
	open var drawEntryLabelsEnabled: Bool
	{
		get
		{
			return _drawEntryLabelsEnabled
		}
		set
		{
			_drawEntryLabelsEnabled = newValue
			setNeedsDisplay()
		}
	}
	
	/// - returns: `true` if drawing entry labels is enabled, `false` ifnot
	open var isDrawEntryLabelsEnabled: Bool
	{
		get
		{
			return drawEntryLabelsEnabled
		}
	}
	
	/// If this is enabled, values inside the GearChart are drawn in percent and not with their original value. Values provided for the ValueFormatter to format are then provided in percent.
	@objc open var usePercentValuesEnabled: Bool
	{
		get
		{
			return _usePercentValuesEnabled
		}
		set
		{
			_usePercentValuesEnabled = newValue
			setNeedsDisplay()
		}
	}
	
	/// - returns: `true` if drawing x-values is enabled, `false` ifnot
	open var isUsePercentValuesEnabled: Bool
	{
		get
		{
			return usePercentValuesEnabled
		}
	}
	
	/// the rectangular radius of the bounding box for the center text, as a percentage of the pie hole
	open var centerTextRadiusPercent: CGFloat
	{
		get
		{
			return _centerTextRadiusPercent
		}
		set
		{
			_centerTextRadiusPercent = newValue
			setNeedsDisplay()
		}
	}
	
	/// The max angle that is used for calculating the pie-circle.
	/// 360 means it's a full pie-chart, 180 results in a half-pie-chart.
	/// **default**: 360.0
	open var maxAngle: CGFloat
	{
		get
		{
			return _maxAngle
		}
		set
		{
			_maxAngle = newValue
			
			if _maxAngle > 360.0
			{
				_maxAngle = 360.0
			}
			
			if _maxAngle < 90.0
			{
				_maxAngle = 90.0
			}
		}
	}
}
