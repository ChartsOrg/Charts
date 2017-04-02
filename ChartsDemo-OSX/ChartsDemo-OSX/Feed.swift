//
//  Feed.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  Copyright © 2017 thierry Hentic.
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Cocoa

class Feed: NSObject
{
    let name: String
    let isSourceGroup :Bool
    var children = [FeedItem]()
    
    class func feedList(_ fileName: String) -> [Feed]
    {
        var feeds = [Feed]()
        
        if let feedList = NSArray(contentsOfFile: fileName) as? [NSDictionary]
        {
            for feedItems in feedList
            {
                let feed = Feed(name: feedItems.object(forKey: "name") as! String, isSourceGroup: feedItems.object(forKey: "isSourceGroup") as! Bool)
                let items = feedItems.object(forKey: "items") as! [NSDictionary]
                
                for dict in items
                {
                    let item = FeedItem(dictionary: dict)
                    feed.children.append(item)
                }
                feed.children.sort { $0.type < $1.type }
                feeds.append(feed)
            }
        }
        feeds.sort { $0.name < $1.name }
        return feeds
    }
    
    init(name: String, isSourceGroup: Bool) {
        self.name = name
        self.isSourceGroup = isSourceGroup
    }
}
