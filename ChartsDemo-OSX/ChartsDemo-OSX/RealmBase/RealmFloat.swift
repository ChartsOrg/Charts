//
//  RealmFloat.swift
//  ChartsDemo-OSX
//
//  Created by thierryH24A on 02/04/2017.
//  Copyright © 2017 dcg. All rights reserved.
//

import Cocoa
import Realm

class RealmFloat: RLMObject
{
    dynamic var floatValue: Float = 0.0
    
    override init() {
        super.init()
    }

    init(floatValue value: Float)
    {
        super.init()
        self.floatValue = value
    }
}
