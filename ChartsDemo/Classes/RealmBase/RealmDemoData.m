//
//  RealmDemoData.m
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/11/2015.
//  Copyright © 2015 dcg. All rights reserved.
//

#import "RealmDemoData.h"

@implementation RealmDemoData

- (id)initWithValue:(float)value xIndex:(int)xIndex xValue:(NSString *)xValue
{
    self = [super init];
    
    if (self)
    {
        self.value = value;
        self.xIndex = xIndex;
        self.xValue = xValue;
    }
    
    return self;
}

- (id)initWithStackValues:(NSArray<NSNumber *> *)stackValues xIndex:(int)xIndex xValue:(NSString *)xValue
{
    self = [super init];
    
    if (self)
    {
        self.xIndex = xIndex;
        self.xValue = xValue;
        self.stackValues = [[RLMArray<RealmFloat> alloc] initWithObjectClassName:@"RealmFloat"];
        
        for (NSNumber *value in stackValues)
        {
            [self.stackValues addObject:[[RealmFloat alloc] initWithFloatValue:value.floatValue]];
        }
    }
    
    return self;
}

@end
