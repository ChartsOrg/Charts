//
//  GearChartDataEntry
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

open class GearChartDataEntry: ChartDataEntry
{
	public required init()
	{
		super.init()
	}
	
	/// - parameter value: The value on the y-axis
	/// - parameter label: The label for the x-axis
	public convenience init(value: Double, label: String?)
	{
		self.init(value: value, label: label, icon: nil, data: nil)
	}
	
	/// - parameter value: The value on the y-axis
	/// - parameter label: The label for the x-axis
	/// - parameter data: Spot for additional data this Entry represents
	public convenience init(value: Double, label: String?, data: AnyObject?)
	{
		self.init(value: value, label: label, icon: nil, data: data)
	}
	
	/// - parameter value: The value on the y-axis
	/// - parameter label: The label for the x-axis
	/// - parameter icon: icon image
	@objc public convenience init(value: Double, label: String?, icon: NSUIImage?)
	{
		self.init(value: value, label: label, icon: icon, data: nil)
	}
	
	/// - parameter value: The value on the y-axis
	/// - parameter label: The label for the x-axis
	/// - parameter icon: icon image
	/// - parameter data: Spot for additional data this Entry represents
	public convenience init(value: Double, label: String?, icon: NSUIImage?, data: AnyObject?)
	{
		self.init(value: value)
		self.label = label
		self.icon = icon
		self.data = data
	}
	
	/// - parameter value: The value on the y-axis
	public convenience init(value: Double)
	{
		self.init(value: value, label: nil, icon: nil, data: nil)
	}
	
	/// - parameter value: The value on the y-axis
	/// - parameter data: Spot for additional data this Entry represents
	public convenience init(value: Double, data: AnyObject?)
	{
		self.init(value: value, label: nil, icon: nil, data: data)
	}
	
	/// - parameter value: The value on the y-axis
	/// - parameter icon: icon image
	public convenience init(value: Double, icon: NSUIImage?)
	{
		self.init(value: value, label: nil, icon: icon, data: nil)
	}
	
	/// - parameter value: The value on the y-axis
	/// - parameter icon: icon image
	/// - parameter data: Spot for additional data this Entry represents
	public convenience init(value: Double, icon: NSUIImage?, data: AnyObject?)
	{
		self.init(value: value, label: nil, icon: icon, data: data)
	}
	
	// MARK: Data property accessors
	
	open var label: String?
	
	open var value: Double
	{
		get { return y }
		set { y = newValue }
	}
	
	
	// MARK: NSCopying
	
	open override func copy(with zone: NSZone? = nil) -> Any
	{
		let copy = super.copy(with: zone) as! GearChartDataEntry
		copy.label = label
		return copy
	}
}
