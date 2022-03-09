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
      Gradient(
        startColor: materialColors[0].cgColor,
        endColor: materialColors[1].cgColor,
        angle: 90
      ),
      Gradient(
        startColor: materialColors[1].cgColor,
        endColor: materialColors[2].cgColor,
        angle: 180
      ),
      Gradient(
        startColor: materialColors[3].cgColor,
        endColor: materialColors[0].cgColor,
        angle: 45
      ),
      Gradient(
        startColor: materialColors[2].cgColor,
        endColor: materialColors[0].cgColor,
        angle: 75
      )
    ]
  }

}
