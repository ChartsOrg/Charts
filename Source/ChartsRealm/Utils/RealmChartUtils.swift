//
//  RealmChartUtils.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
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

extension RLMArray: SequenceType
{
    public func generate() -> NSFastGenerator
    {
        return NSFastGenerator(self)
    }
}