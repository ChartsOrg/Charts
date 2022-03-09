//
//  ChartGradientTemplates.swift
//  Charts
//
//  Created by Kharyton Batkov on 09.03.2022.
//

import Foundation
import CoreGraphics

open class ChartGradientTemplates: NSObject
{
  @objc open class func material () -> [Gradient]
  {
    let materialColors = ChartColorTemplates.material()
    return [
      Gradient(startColor: materialColors[0], endColor: materialColors[1], angle: 90),
      Gradient(startColor: materialColors[1], endColor: materialColors[2], angle: 180),
      Gradient(startColor: materialColors[3], endColor: materialColors[0], angle: 45),
      Gradient(startColor: materialColors[2], endColor: materialColors[0], angle: 75)
    ]
  }

}
