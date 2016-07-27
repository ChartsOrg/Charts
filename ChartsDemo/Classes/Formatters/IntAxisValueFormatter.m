//
//  IntAxisValueFormatter.m
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 22/07/2016.
//  Copyright © 2016 dcg. All rights reserved.
//

#import "IntAxisValueFormatter.h"

@implementation IntAxisValueFormatter
{
}

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
    return [@((NSInteger)value) stringValue];
}

@end
