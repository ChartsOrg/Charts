//
//  ChartHighlight.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

public class ChartHighlight: NSObject
{
    /// the x-index of the highlighted value
    private var _xIndex = Int(0)
    
    /// the index of the dataset the highlighted value is in
    private var _dataSetIndex = Int(0)
    
    /// index which value of a stacked bar entry is highlighted
    /// :default: -1
    private var _stackIndex = Int(-1)

    public override init()
    {
        super.init();
    }
    
    public init(xIndex x: Int, dataSetIndex: Int)
    {
        super.init();
        
        _xIndex = x;
        _dataSetIndex = dataSetIndex;
    }
    
    public init(xIndex x: Int, dataSetIndex: Int, stackIndex: Int)
    {
        super.init();
        
        _xIndex = x;
        _dataSetIndex = dataSetIndex;
        _stackIndex = stackIndex;
    }
    
    public var dataSetIndex: Int { return _dataSetIndex; }
    public var xIndex: Int { return _xIndex; }
    public var stackIndex: Int { return _stackIndex; }
    
    // MARK: NSObject
    
    public override var description: String
    {
        return "Highlight, xIndex: \(_xIndex), dataSetIndex: \(_dataSetIndex), stackIndex (only stacked barentry): \(_stackIndex)";
    }
    
    public override func isEqual(object: AnyObject?) -> Bool
    {
        if (object === nil)
        {
            return false;
        }
        
        if (!object!.isKindOfClass(self.dynamicType))
        {
            return false;
        }
        
        if (object!.xIndex != _xIndex)
        {
            return false;
        }
        
        if (object!.dataSetIndex != _dataSetIndex)
        {
            return false;
        }
        
        if (object!.stackIndex != _stackIndex)
        {
            return false;
        }
        
        return true;
    }
}

func ==(lhs: ChartHighlight, rhs: ChartHighlight) -> Bool
{
    if (lhs === rhs)
    {
        return true;
    }
    
    if (!lhs.isKindOfClass(rhs.dynamicType))
    {
        return false;
    }
    
    if (lhs._xIndex != rhs._xIndex)
    {
        return false;
    }
    
    if (lhs._dataSetIndex != rhs._dataSetIndex)
    {
        return false;
    }
    
    if (lhs._stackIndex != rhs._stackIndex)
    {
        return false;
    }
    
    return true;
}