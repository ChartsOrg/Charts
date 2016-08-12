//
//  RealmDemoData.h
//  ChartsDemo
//  Copyright © 2015 dcg. All rights reserved.
//

#import <Realm/Realm.h>
#import "RealmFloat.h"

@interface RealmDemoData : RLMObject

- (id)initWithYValue:(double)yValue;

- (id)initWithXValue:(double)xValue
              yValue:(double)yValue;

- (id)initWithXValue:(double)xValue
         stackValues:(NSArray<NSNumber *> *)stackValues;

- (id)initWithXValue:(double)xValue
                high:(double)high
                 low:(double)low
                open:(double)open
               close:(double)close;

- (id)initWithXValue:(double)xValue
              yValue:(double)yValue
          bubbleSize:(double)bubbleSize;

/// Constructor for pie chart
- (id)initWithYValue:(double)yValue
               label:(NSString *)label;

@property (nonatomic, assign) double xValue;
@property (nonatomic, assign) double yValue;

@property (nonatomic, assign) double open;
@property (nonatomic, assign) double close;
@property (nonatomic, assign) double high;
@property (nonatomic, assign) double low;

@property (nonatomic, assign) double bubbleSize;

@property (nonatomic, strong) RLMArray<RealmFloat> *stackValues;

@property (nonatomic, strong) NSString *label;

@property (nonatomic, strong) NSString *someStringField;

@end