//
//  BubbleChartDataSet.swift
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
import CoreGraphics;

public class BubbleChartDataSet: BarLineScatterCandleChartDataSet
{
    internal var _xMax = Float(0.0)
    internal var _xMin = Float(0.0)
    internal var _maxSize = Float(1.0)

    public var xMin: Float { return _xMin }
    public var xMax: Float { return _xMax }
    public var maxSize: Float { return _maxSize }
    
    public override func setColor(color: UIColor)
    {
        super.setColor(color.colorWithAlphaComponent(0.5))
    }
    
    internal override func calcMinMax()
    {
        let entries = yVals as! [BubbleChartDataEntry];
    
        //need chart width to guess this properly
        
        for entry in entries
        {
            let ymin = yMin(entry)
            let ymax = yMax(entry)
            
            if (ymin < _yMin)
            {
                _yMin = ymin
            }
            
            if (ymax > _yMax)
            {
                _yMax = ymax;
            }
            
            let xmin = xMin(entry)
            let xmax = xMax(entry)
            
            if (xmin < _xMin)
            {
                _xMin = xmin;
            }
            
            if (xmax > _xMax)
            {
                _xMax = xmax;
            }

            let size = largestSize(entry)
            
            if (size > _maxSize)
            {
                _maxSize = size
            }
        }
    }
    
    private func yMin(entry: BubbleChartDataEntry) -> Float {
        return entry.value
    }
    
    private func yMax(entry: BubbleChartDataEntry) -> Float {
        return entry.value
    }
    
    private func xMin(entry: BubbleChartDataEntry) -> Float {
        return Float(entry.xIndex)
    }
    
    private func xMax(entry: BubbleChartDataEntry) -> Float {
        return Float(entry.xIndex)
    }
    
    private func largestSize(entry: BubbleChartDataEntry) -> Float {
        return entry.size
    }
}
