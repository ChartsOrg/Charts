//
//  GearChartDataSet
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

open class GearChartDataSet: ChartDataSet
{
	@objc(GearChartValuePosition)
	public enum ValuePosition: Int
	{
		case insideSlice
		case outsideSlice
	}
	
	fileprivate func initialize()
	{
		self.valueTextColor = NSUIColor.white
		self.valueFont = NSUIFont.systemFont(ofSize: 13.0)
	}
	
	public required init()
	{
		super.init()
		initialize()
	}
	
	@objc public override init(entries: [ChartDataEntry]?, label: String?)
	{
		super.init(entries: entries ?? [], label: label ?? "")
		initialize()
	}
	
	internal override func calcMinMax(entry e: ChartDataEntry)
	{
		calcMinMaxY(entry: e)
	}
	
	// MARK: - Styling functions and accessors
	
	fileprivate var _sliceSpace = CGFloat(0.0)
	
	/// the space in pixels between the pie-slices
	/// **default**: 0
	/// **maximum**: 20
	open var sliceSpace: CGFloat
	{
		get
		{
			return _sliceSpace
		}
		set
		{
			var space = newValue
			if space > 20.0
			{
				space = 20.0
			}
			if space < 0.0
			{
				space = 0.0
			}
			_sliceSpace = space
		}
	}

	/// When enabled, slice spacing will be 0.0 when the smallest value is going to be smaller than the slice spacing itself.
	open var automaticallyDisableSliceSpacing: Bool = false
	
	/// indicates the selection distance of a pie slice
	open var selectionShift = CGFloat(18.0)
	
	open var xValuePosition: ValuePosition = .insideSlice
	open var yValuePosition: ValuePosition = .insideSlice
	
	/// When valuePosition is OutsideSlice, indicates line color
	open var valueLineColor: NSUIColor? = NSUIColor.black
	
	/// When valuePosition is OutsideSlice, indicates line width
	open var valueLineWidth: CGFloat = 1.0
	
	/// When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
	open var valueLinePart1OffsetPercentage: CGFloat = 0.75
	
	/// When valuePosition is OutsideSlice, indicates length of first half of the line
	open var valueLinePart1Length: CGFloat = 0.3
	
	/// When valuePosition is OutsideSlice, indicates length of second half of the line
	open var valueLinePart2Length: CGFloat = 0.4
	
	/// When valuePosition is OutsideSlice, this allows variable line length
	open var valueLineVariableLength: Bool = true
	
	/// the font for the slice-text labels
	open var entryLabelFont: NSUIFont? = nil
	
	/// the color for the slice-text labels
	open var entryLabelColor: NSUIColor? = nil
	
	/// the color of the background gear
	@objc open var bgGearColor: UIColor? = UIColor.lightGray
	
	/// the color of the gear
	@objc open var gearColor: UIColor? = UIColor.red
	
	/// the gear line width
	@objc open var gearLineWidth: CGFloat = 20.0
	
	
	
	
	// MARK: - NSCopying
	open override func copy(with zone: NSZone? = nil) -> Any
	{
		let copy = super.copy(with: zone) as! GearChartDataSet
		copy._sliceSpace = _sliceSpace
		copy.automaticallyDisableSliceSpacing = automaticallyDisableSliceSpacing
		copy.selectionShift = selectionShift
		copy.xValuePosition = xValuePosition
		copy.yValuePosition = yValuePosition
		copy.valueLineColor = valueLineColor
		copy.valueLineWidth = valueLineWidth
		copy.valueLinePart1OffsetPercentage = valueLinePart1OffsetPercentage
		copy.valueLinePart1Length = valueLinePart1Length
		copy.valueLinePart2Length = valueLinePart2Length
		copy.valueLineVariableLength = valueLineVariableLength
		copy.entryLabelFont = entryLabelFont
		copy.entryLabelColor = entryLabelColor
		copy.bgGearColor = bgGearColor
		copy.gearColor = gearColor
		copy.gearLineWidth = gearLineWidth
		return copy
	}
	
}
