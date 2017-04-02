//
//  RealmDemosViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "RealmDemosViewController.h"
#import "ChartsDemo-Swift.h"

@interface RealmDemosViewController () <ChartViewDelegate>

@end

@implementation RealmDemosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Realm demos";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
