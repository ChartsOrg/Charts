//
//  DayAxisValueFormatter.h
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 22/07/2016.
//  Copyright © 2016 dcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartsDemo-Swift.h"

@interface DayAxisValueFormatter : NSObject <IChartAxisValueFormatter>

- (id)initForChart:(BarLineChartViewBase *)chart;

@end
