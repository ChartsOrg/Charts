//
//  Score.h
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/01/2015.
//  Copyright © 2015 dcg. All rights reserved.
//

#import <Realm/Realm.h>

@interface Score : RLMObject

@property (nonatomic, assign) float totalScore;
@property (nonatomic, assign) double scoreNr;
@property (nonatomic, strong) NSString *playerName;

- (id)initWithTotalScore:(float)totalScore
                 scoreNr:(double)scoreNr
              playerName:(NSString *)playerName;

@end
