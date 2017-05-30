//
//  DemoBaseViewController.swift
//  Ratings
//
//  Created by Nelson Tam on 2015-11-15.
//  Copyright © 2015 Nelson Tam. All rights reserved.
//

import Foundation
import UIKit

protocol DemoBaseViewControllerProtocol {
    var months: Array<String> { get }
    var parties: Array<String> { get }
}

class DemoBaseViewController: UIViewController, DemoBaseViewControllerProtocol, UITableViewDelegate, UITableViewDataSource {
    
    enum Error: ErrorType {
        case InvalidSelection(index: Int)
        case OutOfRange(index: Int)
        case OutOfMemory
    }
    
    var months: Array<String> = Array<String>()
    var parties: Array<String> = Array<String>()
    
    var _optionsTableView : UITableView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initialize()
    }
    
    func initialize() {
        self.edgesForExtendedLayout = UIRectEdge.All
    
        months = [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
            "Oct", "Nov", "Dec"
        ]
    
        parties = [
            "Party A", "Party B", "Party C", "Party D", "Party E", "Party F",
            "Party G", "Party H", "Party I", "Party J", "Party K", "Party L",
            "Party M", "Party N", "Party O", "Party P", "Party Q", "Party R",
            "Party S", "Party T", "Party U", "Party V", "Party W", "Party X",
            "Party Y", "Party Z"
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func optionTapped(key: String) {
    
    }
    
    @IBAction func optionsButtonTapped(sender: Int) {
        if (_optionsTableView != nil)
        {
            _optionsTableView!.removeFromSuperview()
            _optionsTableView = nil
            return;
        }
    
        _optionsTableView = UITableView()
        _optionsTableView!.backgroundColor = UIColor.init(white: 0, alpha: 0.9)
        _optionsTableView!.delegate = self
        _optionsTableView!.dataSource = self
    
        _optionsTableView!.translatesAutoresizingMaskIntoConstraints = false
    
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: _optionsTableView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 40))
    
        constraints.append(NSLayoutConstraint(item: _optionsTableView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: sender, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: _optionsTableView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: sender, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 5))

    
        self.view.addSubview(_optionsTableView!)
    
        self.view.addConstraints(constraints)
    
        _optionsTableView!.addConstraints([
            NSLayoutConstraint(item: _optionsTableView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 220)
            
            ])
    }
    
    //pragma mark - UITableViewDelegate, UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView : UITableView) -> Int {
        if (tableView == _optionsTableView)
        {
            return 1;
        }
    
        return 0;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView == _optionsTableView)
        {
            return 40.0;
        }
    
        return 44.0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if ((cell == nil)) {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            cell!.backgroundView = nil;
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel!.textColor = UIColor.whiteColor()
        }
        
        cell!.textLabel!.text = ""
        
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == _optionsTableView)
        {
            tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
            if ((_optionsTableView) != nil)
            {
                _optionsTableView!.removeFromSuperview()
                _optionsTableView = nil;
            }
    
            self.optionTapped("")
        }
    }
    
}
