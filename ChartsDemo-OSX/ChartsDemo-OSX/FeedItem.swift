//
//  FeedItem.swift
//  Reader
//
//  Created by Jean-Pierre Distler on 19.01.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

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
