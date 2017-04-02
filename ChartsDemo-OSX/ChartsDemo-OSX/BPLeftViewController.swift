//
//  BPLeftViewController.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  Copyright © 2017 thierry Hentic.
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Cocoa
import Charts


class BPLeftViewController: NSViewController
{
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    var feeds = [Feed]()
    
    override open func viewDidAppear()
    {
        super.viewDidAppear()
        
        outlineView.expandItem(nil, expandChildren: true)
        outlineView.selectionHighlightStyle = .sourceList
        outlineView.scrollRowToVisible(0)
        
        let array = [1]
        outlineView.selectRowIndexes(IndexSet(array), byExtendingSelection: false)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do view setup here.
        
        if let filePath = Bundle.main.path(forResource: "Feeds", ofType: "plist")
        {
            feeds = Feed.feedList(filePath)
        }
    }
    
    override var representedObject: Any?
        {
        didSet
        {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func doubleClickedItem(_ sender: NSOutlineView)
    {
        let item = sender.item(atRow: sender.clickedRow)
        
        if item is Feed {
            //3
            if sender.isItemExpanded(item) {
                sender.collapseItem(item)
            } else {
                sender.expandItem(item)
            }
        }
    }
}

extension BPLeftViewController: NSOutlineViewDataSource
{
    //ok-------
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
        if let feed = item as? Feed {
            return feed.children.count
        }
        //2
        return feeds.count
    }
    
    //ok--------------
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        if let feed = item as? Feed
        {
            return feed.children[index]
        }
        return feeds[index]
    }
    
    //ok---------------
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        if let feed = item as? Feed
        {
            return feed.children.count > 0
        }
        return false
    }
    
    
    //	Don't show the expander triangle for group items..
    // ok
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool
    {
        return isSourceGroupItem(item)
    }
    
    // ok
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        return !self.isSourceGroupItem(item)
    }
    
    // ok
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool
    {
        return isSourceGroupItem(item)
    }
    
    // ok
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        //	Make the height of Source Group items a little higher
        if self.isSourceGroupItem(item) {
            return outlineView.rowHeight + 5.0
        }
        return outlineView.rowHeight
    }
    
    //	Method to determine if an outline item is a source group
    // ok
    func isSourceGroupItem(_ item: Any) -> Bool
    {
        if let feed = item as? Feed
        {
            return feed.isSourceGroup
        }
        return false
    }
}

extension BPLeftViewController: NSOutlineViewDelegate
{
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        var view: NSTableCellView?
        
        if let feed = item as? Feed
        {
            view = outlineView.make(withIdentifier: "FeedCell", owner: self) as? NSTableCellView
            if let textField = view?.textField
            {
                textField.stringValue = feed.name.uppercased()
                //                textField.font = NSFont.boldSystemFont(ofSize: 14.0)
                
            }
        }
        else
        {
            if let feedItem = item as? FeedItem
            {
                view = outlineView.make(withIdentifier: "FeedItemCell", owner: self) as? NSTableCellView
                if let textField = view?.textField
                {
                    textField.stringValue = feedItem.type
                    //textField.textColor = NSUIColor.black
                }
            }
        }
        return view
    }
    
    //NSOutlineViewDelegate
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        
        let selectedIndex = outlineView.selectedRow
        
        if let feedItem = outlineView.item(atRow: selectedIndex) as? FeedItem
        {
            //3
            let name =  feedItem.name
            let id =  feedItem.id
            //4
            if name == "main"
            {
                let svc = self.parent as! NSSplitViewController
                
                let vc = self.storyboard?.instantiateController(withIdentifier: id) as! NSViewController
                let svi = NSSplitViewItem(viewController: vc)
                
                svc.removeSplitViewItem(svc.splitViewItems[1] )
                svc.insertSplitViewItem(svi, at: 1)
            }
            else
            {
                // vue à afficher
                let svc = self.parent as! NSSplitViewController
                
                let sb = NSStoryboard(name: name, bundle: nil)
                let vc = sb.instantiateController(withIdentifier: id) as! NSViewController
                let svi = NSSplitViewItem(viewController: vc)
                
                svc.removeSplitViewItem(svc.splitViewItems[1] )
                svc.insertSplitViewItem(svi, at: 1)
            }
        }
    }
    
}

extension NSMutableAttributedString {
    func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : NSUIFont(name: "AvenirNext-Medium", size: 12)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}

