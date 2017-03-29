//
//  SplitViewController.swift
//  splitTest
//
//  Created by thierryH24A on 17/12/2016.
//  Copyright © 2016 thierryH24A. All rights reserved.
//

import Cocoa



class SplitViewController: NSSplitViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
        
    override var representedObject: Any?
        {
        didSet
        {
           /* if let url = representedObject as? URL
            {
            }*/
        }
    }
}
