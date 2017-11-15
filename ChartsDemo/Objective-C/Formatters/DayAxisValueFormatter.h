//
//  DayAxisValueFormatter.h
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartsDemo-Swift.h"

@interface DayAxisValueFormatter : NSObject <ChartAxisValueFormatter>

- (id)initForChart:(BarLineChartViewBase *)chart;

@end
