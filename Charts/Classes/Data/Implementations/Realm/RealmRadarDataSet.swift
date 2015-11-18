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
    private func initialize()
    {
        self.valueFont = UIFont.systemFontOfSize(13.0)
    }
    
    public required init()
    {
        super.init()
    }
    
    public override init(results: RLMResults?, yValueField: String, xIndexField: String, label: String?)
    {
        super.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: label)
        initialize()
    }
    
    public convenience init(results: RLMResults?, yValueField: String, xIndexField: String)
    {
        self.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: "DataSet")
        initialize()
    }
    
    public override init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xIndexField: String, label: String?)
    {
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xIndexField: xIndexField, label: label)
        initialize()
    }
    
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
}