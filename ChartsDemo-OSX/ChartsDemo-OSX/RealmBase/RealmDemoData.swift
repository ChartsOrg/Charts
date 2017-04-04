//
//  RealmDemoData.swift
//  ChartsDemo-OSX
//
//  Created by thierryH24A on 02/04/2017.
//  Copyright © 2017 dcg. All rights reserved.
//

import Cocoa
import Realm

class RealmDemoData: RLMObject
{
    dynamic var xValue = 0.0
    dynamic var yValue = 0.0
    
    dynamic var open = 0.0
    dynamic var close = 0.0
    dynamic var high = 0.0
    dynamic var low = 0.0
    
    dynamic var bubbleSize = 0.0

    dynamic var stackValues = RLMArray(objectClassName: "RealmFloat")
    
    dynamic var label = ""
    dynamic var someStringField = ""
    
    override init() {
        super.init()
    }
    
    init(yValue: Double) {
        super.init()
        
        self.yValue = yValue
    }
    
    init(xValue: Double, yValue: Double) {
        super.init()
        
        self.xValue = xValue
        self.yValue = yValue
    }
    
    init(xValue: Double, stackValues: [NSNumber]) {
        super.init()
        
        self.xValue = xValue
        
        for value: NSNumber in stackValues
        {
            self.stackValues.add(RealmFloat(floatValue: CFloat(value)))
        }
    }
    
    init(xValue: Double, high: Double, low: Double, open: Double, close: Double)
    {
        super.init()
        
        self.xValue = xValue
        yValue = (high + low) / 2.0
        self.high = high
        self.low = low
        self.open = open
        self.close = close
    }
    
    init(xValue: Double, yValue: Double, bubbleSize: Double) {
        super.init()
        
        self.xValue = xValue
        self.yValue = yValue
        self.bubbleSize = bubbleSize
    }

    init(yValue: Double, label: String) {
        super.init()
        
        self.yValue = yValue
        self.label = label
    }
}
