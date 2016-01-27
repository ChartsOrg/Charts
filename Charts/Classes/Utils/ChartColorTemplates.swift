//
//  ChartColorTemplates.swift
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

public class ChartColorTemplates: NSObject
{
    public class func liberty () -> [UIColor]
    {
        return [
            UIColor(red: 207/255.0, green: 248/255.0, blue: 246/255.0, alpha: 1.0),
            UIColor(red: 148/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1.0),
            UIColor(red: 136/255.0, green: 180/255.0, blue: 187/255.0, alpha: 1.0),
            UIColor(red: 118/255.0, green: 174/255.0, blue: 175/255.0, alpha: 1.0),
            UIColor(red: 42/255.0, green: 109/255.0, blue: 130/255.0, alpha: 1.0)
        ]
    }
    
    public class func joyful () -> [UIColor]
    {
        return [
            UIColor(red: 217/255.0, green: 80/255.0, blue: 138/255.0, alpha: 1.0),
            UIColor(red: 254/255.0, green: 149/255.0, blue: 7/255.0, alpha: 1.0),
            UIColor(red: 254/255.0, green: 247/255.0, blue: 120/255.0, alpha: 1.0),
            UIColor(red: 106/255.0, green: 167/255.0, blue: 134/255.0, alpha: 1.0),
            UIColor(red: 53/255.0, green: 194/255.0, blue: 209/255.0, alpha: 1.0)
        ]
    }
    
    public class func pastel () -> [UIColor]
    {
        return [
            UIColor(red: 64/255.0, green: 89/255.0, blue: 128/255.0, alpha: 1.0),
            UIColor(red: 149/255.0, green: 165/255.0, blue: 124/255.0, alpha: 1.0),
            UIColor(red: 217/255.0, green: 184/255.0, blue: 162/255.0, alpha: 1.0),
            UIColor(red: 191/255.0, green: 134/255.0, blue: 134/255.0, alpha: 1.0),
            UIColor(red: 179/255.0, green: 48/255.0, blue: 80/255.0, alpha: 1.0)
        ]
    }
    
    public class func colorful () -> [UIColor]
    {
        return [
            UIColor(red: 193/255.0, green: 37/255.0, blue: 82/255.0, alpha: 1.0),
            UIColor(red: 255/255.0, green: 102/255.0, blue: 0/255.0, alpha: 1.0),
            UIColor(red: 245/255.0, green: 199/255.0, blue: 0/255.0, alpha: 1.0),
            UIColor(red: 106/255.0, green: 150/255.0, blue: 31/255.0, alpha: 1.0),
            UIColor(red: 179/255.0, green: 100/255.0, blue: 53/255.0, alpha: 1.0)
        ]
    }
    
    public class func vordiplom () -> [UIColor]
    {
        return [
            UIColor(red: 192/255.0, green: 255/255.0, blue: 140/255.0, alpha: 1.0),
            UIColor(red: 255/255.0, green: 247/255.0, blue: 140/255.0, alpha: 1.0),
            UIColor(red: 255/255.0, green: 208/255.0, blue: 140/255.0, alpha: 1.0),
            UIColor(red: 140/255.0, green: 234/255.0, blue: 255/255.0, alpha: 1.0),
            UIColor(red: 255/255.0, green: 140/255.0, blue: 157/255.0, alpha: 1.0)
        ]
    }
    
    public class func colorFromString(colorString: String) -> UIColor
    {
        let leftParenCharset: NSCharacterSet = NSCharacterSet(charactersInString: "( ")
        let commaCharset: NSCharacterSet = NSCharacterSet(charactersInString: ", ")

        let colorString = colorString.lowercaseString
        
        if colorString.hasPrefix("#")
        {
            var argb: [UInt] = [255, 0, 0, 0]
            let colorString = colorString.unicodeScalars
            var length = colorString.count
            var index = colorString.startIndex
            let endIndex = colorString.endIndex
            
            if length % 2 == 1
            {
                index = index.advancedBy(1)
                length = length - 1
            }
            
            if length == 3 || length == 6 || length == 8
            {
                var i = length == 8 ? 0 : 1
                while index < endIndex
                {
                    var c = colorString[index]
                    index = index.advancedBy(1)
                    
                    var val = (c.value >= 0x61 && c.value <= 0x66) ? (c.value - 0x61 + 10) : c.value - 0x30
                    argb[i] = UInt(val) * 16
                    if length == 3
                    {
                        argb[i] = argb[i] + UInt(val)
                    }
                    else
                    {
                        c = colorString[index]
                        index = index.advancedBy(1)
                        
                        val = (c.value >= 0x61 && c.value <= 0x66) ? (c.value - 0x61 + 10) : c.value - 0x30
                        argb[i] = argb[i] + UInt(val)
                    }
                    
                    i = i + 1
                }
            }
            
            return UIColor(red: CGFloat(argb[1]) / 255.0, green: CGFloat(argb[2]) / 255.0, blue: CGFloat(argb[3]) / 255.0, alpha: CGFloat(argb[0]) / 255.0)
        }
        else if colorString.hasPrefix("rgba")
        {
            var a: Float = 1.0
            var r: Int32 = 0
            var g: Int32 = 0
            var b: Int32 = 0
            let scanner: NSScanner = NSScanner(string: colorString)
            scanner.scanString("rgba", intoString: nil)
            scanner.scanCharactersFromSet(leftParenCharset, intoString: nil)
            scanner.scanInt(&r)
            scanner.scanCharactersFromSet(commaCharset, intoString: nil)
            scanner.scanInt(&g)
            scanner.scanCharactersFromSet(commaCharset, intoString: nil)
            scanner.scanInt(&b)
            scanner.scanCharactersFromSet(commaCharset, intoString: nil)
            scanner.scanFloat(&a)
            return UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: CGFloat(a)
            )
        }
        else if colorString.hasPrefix("argb")
        {
            var a: Float = 1.0
            var r: Int32 = 0
            var g: Int32 = 0
            var b: Int32 = 0
            let scanner: NSScanner = NSScanner(string: colorString)
            scanner.scanString("argb", intoString: nil)
            scanner.scanCharactersFromSet(leftParenCharset, intoString: nil)
            scanner.scanFloat(&a)
            scanner.scanCharactersFromSet(commaCharset, intoString: nil)
            scanner.scanInt(&r)
            scanner.scanCharactersFromSet(commaCharset, intoString: nil)
            scanner.scanInt(&g)
            scanner.scanCharactersFromSet(commaCharset, intoString: nil)
            scanner.scanInt(&b)
            return UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: CGFloat(a)
            )
        }
        else if colorString.hasPrefix("rgb")
        {
            var r: Int32 = 0
            var g: Int32 = 0
            var b: Int32 = 0
            let scanner: NSScanner = NSScanner(string: colorString)
            scanner.scanString("rgb", intoString: nil)
            scanner.scanCharactersFromSet(leftParenCharset, intoString: nil)
            scanner.scanInt(&r)
            scanner.scanCharactersFromSet(commaCharset, intoString: nil)
            scanner.scanInt(&g)
            scanner.scanCharactersFromSet(commaCharset, intoString: nil)
            scanner.scanInt(&b)
            return UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: 1.0
            )
        }
        
        return UIColor.clearColor()
    }
}