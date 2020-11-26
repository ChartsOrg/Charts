//
//  GearChartData
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class GearChartData: ChartData
{
	public required init()
	{
		super.init()
	}
	
	public override init(dataSets: [ChartDataSetProtocol]?)
	{
		super.init(dataSets: dataSets ?? [])
	}
	
	public required init(arrayLiteral elements: Element...) {
		fatalError("init(arrayLiteral:) has not been implemented")
	}
	
	var dataSet: GearChartDataSetProtocol?
	{
		get
		{
			return dataSets.count > 0 ? dataSets[0] as? GearChartDataSetProtocol : nil
		}
		set
		{
			if newValue != nil
			{
				dataSets = [newValue!]
			}
			else
			{
				dataSets = []
			}
		}
	}
	
	open func getDataSetByIndex(_ index: Int) -> ChartDataSetProtocol?
	{
		if index != 0
		{
			return nil
		}
		return super.dataSet(at: index)
	}
	
	open func getDataSetByLabel(_ label: String, ignorecase: Bool) -> ChartDataSetProtocol?
	{
		if dataSets.count == 0 || dataSets[0].label == nil
		{
			return nil
		}
		
		if ignorecase
		{
			if (label.caseInsensitiveCompare(dataSets[0].label!) == ComparisonResult.orderedSame)
			{
				return dataSets[0]
			}
		}
		else
		{
			if label == dataSets[0].label
			{
				return dataSets[0]
			}
		}
		return nil
	}
	
	open  func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
	{
		return dataSet?.entryForIndex(Int(highlight.x))
	}
	
	open func addDataSet(_ d: ChartDataSetProtocol!)
	{
		super.append(d)
	}
	
	/// Removes the DataSet at the given index in the DataSet array from the data object.
	/// Also recalculates all minimum and maximum values.
	///
	/// - returns: `true` if a DataSet was removed, `false` ifno DataSet could be removed.
	open func removeDataSetByIndex(_ index: Int) -> Bool
	{
		if index >= _dataSets.count || index < 0
		{
			return false
		}
		
		return false
	}
	
	/// - returns: The total y-value sum across all DataSet objects the this object represents.
	open var yValueSum: Double
	{
		guard let dataSet = dataSet else { return 0.0 }
		
		var yValueSum: Double = 0.0
		
		for i in 0..<dataSet.entryCount
		{
			yValueSum += dataSet.entryForIndex(i)?.y ?? 0.0
		}
		
		return yValueSum
	}
}
