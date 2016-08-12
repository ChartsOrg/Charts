//
//  RealmDemoData.m
//  ChartsDemo
//  Copyright © 2015 dcg. All rights reserved.
//

#import "RealmDemoData.h"

@implementation RealmDemoData

- (id)initWithYValue:(double)yValue
{
    self = [super init];
    
    if (self)
    {
        self.yValue = yValue;
    }
    
    return self;
}

- (id)initWithXValue:(double)xValue
              yValue:(double)yValue
{
    self = [super init];
    
    if (self)
    {
        self.xValue = xValue;
        self.yValue = yValue;
    }
    
    return self;
}

- (id)initWithXValue:(double)xValue
         stackValues:(NSArray<NSNumber *> *)stackValues
{
    self = [super init];
    
    if (self)
    {
        self.xValue = xValue;
        self.stackValues = [[RLMArray<RealmFloat> alloc] initWithObjectClassName:@"RealmFloat"];
        
        for (NSNumber *value in stackValues)
        {
            [self.stackValues addObject:[[RealmFloat alloc] initWithFloatValue:value.floatValue]];
        }
    }
    
    return self;
}

- (id)initWithXValue:(double)xValue
                high:(double)high
                 low:(double)low
                open:(double)open
               close:(double)close
{
    self = [super init];
    
    if (self)
    {
        self.xValue = xValue;
        self.yValue = (high + low) / 2.f;
        self.high = high;
        self.low = low;
        self.open = open;
        self.close = close;
    }
    
    return self;
}

- (id)initWithXValue:(double)xValue
              yValue:(double)yValue
          bubbleSize:(double)bubbleSize
{
    self = [super init];
    
    if (self)
    {
        self.xValue = xValue;
        self.yValue = yValue;
        self.bubbleSize = bubbleSize;
    }
    
    return self;
}

- (id)initWithYValue:(double)yValue
               label:(NSString *)label
{
    self = [super init];
    
    if (self)
    {
        self.yValue = yValue;
        self.label = label;
    }
    
    return self;
}

@end
