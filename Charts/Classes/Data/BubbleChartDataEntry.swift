//
//  BubbleDataEntry.swift
//  Charts
//
//  Copyright 2015 Pierre-Marc Airoldi
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

public class BubbleChartDataEntry: ChartDataEntry
{
    /// size value
    public var size = Float(0.0)
    
    public init(xIndex: Int, value:Float, size: Float)
    {
        super.init(value: value, xIndex: xIndex)
        
        self.size = size
    }
    
    public init(xIndex: Int, value:Float, size: Float, data: AnyObject?)
    {
        super.init(value: value, xIndex: xIndex, data: data)
      
        self.size = size
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = super.copyWithZone(zone) as! BubbleChartDataEntry;
        copy.size = size;
        return copy;
    }
}