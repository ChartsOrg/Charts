//
//  ComponentBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


/// This class encapsulates everything both Axis, Legend and LimitLines have in common
@objc(ChartComponentBase)
open class ComponentBase: NSObject
    /// The offset this component has on the x-axis
    /// **default**: 5.0
    @objc open var xOffset = CGFloat(5.0)
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0 (or 0.0 on ChartYAxis)
    @objc open var yOffset = CGFloat(5.0)
    
    public override init()
    {
        super.init()
    }

    /// flag that indicates if this component is enabled or not
    @objc public var isEnabled: Bool {
        get { return _isEnabled }
        @objc(setEnabled:) set { _isEnabled = newValue }
    }
    private var _isEnabled = true
}
