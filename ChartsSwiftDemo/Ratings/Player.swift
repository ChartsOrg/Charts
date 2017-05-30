//
//  Player.swift
//  Ratings
//
//  Created by Nelson Tam on 2015-11-14.
//  Copyright © 2015 Nelson Tam. All rights reserved.
//

import Foundation

import UIKit

struct ChartElement {
    var title: String?
    var subTitle: String?
    var rating: Int
    var controller: String
    
    init(title: String?, subTitle: String?, rating: Int, controller: String) {
        self.title = title
        self.subTitle = subTitle
        self.rating = rating
        self.controller = controller
    }
}