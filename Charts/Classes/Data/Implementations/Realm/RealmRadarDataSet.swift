//
//  RealmRadarDataSet.swift
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
import UIKit
import Realm
import Realm.Dynamic

public class RealmRadarDataSet: RealmLineRadarDataSet, IRadarChartDataSet
{
    public override func initialize()
    {
        self.valueFont = UIFont.systemFontOfSize(13.0)
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
}