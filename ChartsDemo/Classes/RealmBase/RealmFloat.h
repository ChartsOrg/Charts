//
//  RealmFloat.h
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/11/2015.
//  Copyright © 2015 dcg. All rights reserved.
//

#import <Realm/Realm.h>

@interface RealmFloat : RLMObject

@property (nonatomic, assign) float floatValue;

- (id)initWithFloatValue:(float)value;

@end

RLM_ARRAY_TYPE(RealmFloat)