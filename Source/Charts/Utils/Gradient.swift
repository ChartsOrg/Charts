//
//  Gradient.swift
//  Charts
//
//  Created by Kharyton Batkov on 09.03.2022.
//

import Foundation

@objc
open class Gradient: NSObject {
  let startColor: NSUIColor
  let endColor: NSUIColor
  let startPoint: CGPoint
  let endPoint: CGPoint
  
  init(startColor: NSUIColor, endColor: NSUIColor, angle: CGFloat) {
    self.startColor = startColor
    self.endColor = endColor
    let points = Self.calculatePoints(for: angle)
    startPoint = points.0
    endPoint = points.0
    super.init()
  }
  
}

extension Gradient {
  var locations: [CGFloat] { [0, 1] }
  var colors: CFArray { [startColor.cgColor, endColor.cgColor] as CFArray }
  
  var cgGradient: CGGradient {
    CGGradient(
      colorsSpace: nil,
      colors: colors,
      locations: locations)!
  }
  
  func startPoint(in rect: CGRect) -> CGPoint {
    CGPoint(x: rect.midX, y: rect.minY)
    //CGPoint(x: startPoint.x * rect.minX, y: startPoint.y * rect.minY)
  }
  
  func endPoint(in rect: CGRect) -> CGPoint {
    CGPoint(x: rect.midX, y: rect.maxY)
    //CGPoint(x: endPoint.x * rect.maxX, y: endPoint.y * rect.maxY)
  }
}

extension Gradient {
  
  private static func calculatePoints(for angle: CGFloat) -> (CGPoint, CGPoint) {
    var ang = (-angle).truncatingRemainder(dividingBy: 360)
    
    if ang < 0 { ang = 360 + ang }
    
    let n: CGFloat = 0.5
    
    switch ang {
    case 0 ... 45, 315 ... 360:
      let a = CGPoint(x: 0, y: n * tanx(ang) + n)
      let b = CGPoint(x: 1, y: n * tanx(-ang) + n)
      return (a, b)
      
    case 45 ... 135:
      let a = CGPoint(x: n * tanx(ang - 90) + n, y: 1)
      let b = CGPoint(x: n * tanx(-ang - 90) + n, y: 0)
      return (a, b)
      
    case 135 ... 225:
      let a = CGPoint(x: 1, y: n * tanx(-ang) + n)
      let b = CGPoint(x: 0, y: n * tanx(ang) + n)
      return (a, b)
      
    case 225 ... 315:
      let a = CGPoint(x: n * tanx(-ang - 90) + n, y: 0)
      let b = CGPoint(x: n * tanx(ang - 90) + n, y: 1)
      return (a, b)
      
    default:
      let a = CGPoint(x: 0, y: n)
      let b = CGPoint(x: 1, y: n)
      return (a, b)
    }
  }
  
  private static func tanx(_ 𝜽: CGFloat) -> CGFloat {
    return tan(𝜽 * CGFloat.pi / 180)
  }
}
