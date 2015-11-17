//
//  RealmDemoBaseViewController.h
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 13/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

#import <UIKit/UIKit.h>
#import "DemoBaseViewController.h"

@interface RealmDemoBaseViewController : DemoBaseViewController

- (void)writeRandomDataToDbWithObjectCount:(NSInteger)objectCount;
- (void)writeRandomStackedDataToDbWithObjectCount:(NSInteger)objectCount;

@end
