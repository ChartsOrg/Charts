//
//  RealmHelpers.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 6/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import Realm

extension RLMResults: SequenceType
{
    public func generate() -> NSFastGenerator
    {
        return NSFastGenerator(self)
    }
}