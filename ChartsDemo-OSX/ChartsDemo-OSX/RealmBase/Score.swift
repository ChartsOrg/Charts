//
//  Score.swift
//  ChartsDemo-OSX
//
//  Created by thierryH24A on 02/04/2017.
//  Copyright © 2017 dcg. All rights reserved.
//

import Cocoa
import Realm


class Score: RLMObject
{
    dynamic var totalScore: Float = 0.0
    dynamic var scoreNr = 0.0
    dynamic var playerName = ""
    
    override init() {
        super.init()
    }

    init(totalScore: Float, scoreNr: Double, playerName: String)
    {
        super.init()
        
        self.totalScore = totalScore
        self.scoreNr = scoreNr
        self.playerName = playerName
    }
}
