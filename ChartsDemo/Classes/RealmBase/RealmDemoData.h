//
//  RealmDemoData.h
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/11/2015.
//  Copyright © 2015 dcg. All rights reserved.
//

#import <Realm/Realm.h>
#import "RealmFloat.h"

@interface RealmDemoData : RLMObject

- (id)initWithValue:(float)value xIndex:(int)xIndex xValue:(NSString *)xValue;
- (id)initWithStackValues:(NSArray<NSNumber *> *)stackValues xIndex:(int)xIndex xValue:(NSString *)xValue;
    
@property (nonatomic, assign) float value;
@property (nonatomic, strong) RLMArray<RealmFloat> *stackValues;
@property (nonatomic, assign) int xIndex;

@property (nonatomic, strong) NSString *xValue;

@property (nonatomic, strong) NSString *someStringField;

@end