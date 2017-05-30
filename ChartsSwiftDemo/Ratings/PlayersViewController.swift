//
//  PlayersViewController.swift
//  Ratings
//
//  Created by Nelson Tam on 2015-11-14.
//  Copyright © 2015 Nelson Tam. All rights reserved.
//

import Foundation
import UIKit

/*
extension NSObject {
    // create a static method to get a swift class for a string name
    class func swiftClassFromString(className: String) -> AnyClass! {
        // get the project name
        if  var appName: String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String? {
            // generate the full name of your class (take a look into your "YourProject-swift.h" file)
            let classStringName: String = "_TtC\(appName!.utf16count)\(appName)\(countElements(className))\(className)"
            // return the class!
            return NSClassFromString(classStringName)
        }
        return nil;
    }
}
*/

class PlayersViewController : UITableViewController {
    var players:[ChartElement] = chartTypeData

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // any custom init code you want
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell", forIndexPath: indexPath) //1
        
        let chartDataElement = chartTypeData[indexPath.row]
        
        if let titleLabel = cell.viewWithTag(100) as? UILabel { //3
            titleLabel.text = chartDataElement.title
        }
        if let subTitleLabel = cell.viewWithTag(101) as? UILabel {
            subTitleLabel.text = chartDataElement.subTitle
        }
        if let ratingImageView = cell.viewWithTag(102) as? UIImageView {
            ratingImageView.image = self.imageForRating(chartDataElement.rating)
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let def: ChartElement = chartTypeData[indexPath.row]
    
        //let vcClass : NSObject.Type = def["class"]!
        //var instance : NSObject = vcClass.init()
        //let vc: UIViewController = instance as! UIViewController
        //self.navigationController!.pushViewController(vc, animated: true)
        navigateToController("Main", viewControllerName:def.controller)
    
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // *******
    // Helpers
    // *******
    func navigateToController(storyBoardName: String, viewControllerName: String) -> Bool {
        //let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        //var rootViewController = appDelegate.window!.rootViewController! as! UIViewController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: storyBoardName, bundle: nil)
        let viewControllerInstance = mainStoryboard.instantiateViewControllerWithIdentifier(viewControllerName) as UIViewController
        self.navigationController?.pushViewController(viewControllerInstance, animated: true)
        
        return true
        
    }
    
    func imageForRating(rating:Int) -> UIImage? {
        let imageName = "\(rating)Stars"
        return UIImage(named: imageName)
    }

}
