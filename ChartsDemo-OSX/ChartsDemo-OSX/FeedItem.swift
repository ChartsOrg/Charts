//
//  FeedItem.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  Copyright © 2017 thierry Hentic.
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Cocoa

class FeedItem: NSObject {
    let type: String
    let comment : String
    let id : String
    let name : String
    
    init(dictionary: NSDictionary) {
        self.type = dictionary.object(forKey: "type") as! String
        self.comment = dictionary.object(forKey: "description") as! String
        self.id = dictionary.object(forKey: "id") as! String
        self.name = dictionary.object(forKey: "name") as! String
    }
}
