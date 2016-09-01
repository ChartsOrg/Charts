//
//  Score.m
//  ChartsDemo
//  Copyright © 2015 dcg. All rights reserved.
//

#import "Score.h"

@implementation Score

- (id)initWithTotalScore:(float)totalScore
                 scoreNr:(double)scoreNr
              playerName:(NSString *)playerName
{
    self = [super init];
    
    if (self)
    {
        self.totalScore = totalScore;
        self.scoreNr = scoreNr;
        self.playerName = playerName;
    }
    
    return self;
}

@end
