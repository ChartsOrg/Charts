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
@property (nonatomic, assign) NSInteger scoreNr;
@property (nonatomic, strong) NSString *playerName;

- (id)initWithTotalScore:(float)totalScore
                 scoreNr:(NSInteger)scoreNr
              playerName:(NSString *)playerName;

@end
