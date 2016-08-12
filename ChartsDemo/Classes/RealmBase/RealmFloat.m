//
//  RealmFloat.m
//  ChartsDemo
//  Copyright © 2015 dcg. All rights reserved.
//

#import "RealmFloat.h"

@implementation RealmFloat

- (id)initWithFloatValue:(float)value
{
    self = [super init];
    
    if (self)
    {
        self.floatValue = value;
    }
    
    return self;
}

@end
