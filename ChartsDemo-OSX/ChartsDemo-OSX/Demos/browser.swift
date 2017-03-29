//
//  browser.swift
//  graphDemoChartOSX
//
//  Created by thierryH24A on 15/02/2017.
//  Copyright © 2017 thierryH24A. All rights reserved.
//

import Foundation

import Cocoa

class Browser: NSObject
{
    let name: String
    let y :String
    var drillDown = [BrowserItem]()
    
    class func browserList(_ fileName: String) -> [Browser]
    {
        var browsers = [Browser]()
        
        if let browserList = NSArray(contentsOfFile: fileName) as? [NSDictionary]
        {
            for browserItems in browserList
            {
                let browser = Browser(name: browserItems.object(forKey: "name") as! String, y: browserItems.object(forKey: "y") as! String)
                let items = browserItems.object(forKey: "drillDown") as! [NSDictionary]
                
                for dict in items
                {
                    let item = BrowserItem(dictionary: dict)
                    browser.drillDown.append(item)
                }
                browsers.append(browser)
            }
        }
        return browsers
    }
    
    init(name: String, y: String) {
        self.name = name
        self.y = y
    }
}

class BrowserItem: NSObject {
    let version: String
    let pdm : String
    
    init(dictionary: NSDictionary) {
        self.version = dictionary.object(forKey: "version") as! String
        self.pdm = dictionary.object(forKey: "pdm") as! String
     }
}
