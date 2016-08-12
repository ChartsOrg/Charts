//
//  RealmDemoBaseViewController.h
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import <UIKit/UIKit.h>
#import "DemoBaseViewController.h"

@interface RealmDemoBaseViewController : DemoBaseViewController

- (void)writeRandomDataToDbWithObjectCount:(NSInteger)objectCount;
- (void)writeRandomStackedDataToDbWithObjectCount:(NSInteger)objectCount;
- (void)writeRandomCandleDataToDbWithObjectCount:(NSInteger)objectCount;
- (void)writeRandomBubbleDataToDbWithObjectCount:(NSInteger)objectCount;
- (void)writeRandomPieDataToDb;

- (void)styleData:(ChartData *)data;

@end
