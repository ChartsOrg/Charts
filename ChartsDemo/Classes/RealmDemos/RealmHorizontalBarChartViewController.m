//
//  RealmHorizontalBarChartViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "RealmHorizontalBarChartViewController.h"
#import "ChartsDemo-Swift.h"
#import <Realm/Realm.h>
#import "RealmDemoData.h"

@interface RealmHorizontalBarChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet HorizontalBarChartView *chartView;

@end

@implementation RealmHorizontalBarChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self writeRandomStackedDataToDbWithObjectCount:50];
    
    self.title = @"Realm.io Horizontal Bar Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     ];
    
    _chartView.delegate = self;
    
    [self setupBarLineChartView:_chartView];
    
    _chartView.leftAxis.axisMinimum = 0.0;
    _chartView.drawValueAboveBarEnabled = NO;

    [self setData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setData
{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *results = [RealmDemoData allObjectsInRealm:realm];
    
    // RealmBarDataSet *set = [[RealmBarDataSet alloc] initWithResults:results yValueField:@@"yValue" xValueField:@"xIndex"];
    RealmBarDataSet *set = [[RealmBarDataSet alloc] initWithResults:results xValueField:@"xValue" yValueField:@"stackValues" stackValueField:@"floatValue"]; // stacked entries

    set.colors = @[
                   [ChartColorTemplates colorFromString:@"#8BC34A"],
                   [ChartColorTemplates colorFromString:@"#FFC107"],
                   [ChartColorTemplates colorFromString:@"#9E9E9E"],
                   ];

    set.label = @"Mobile OS Distribution";
    set.stackLabels = @[
                        @"iOS",
                        @"Android",
                        @"Other"
                        ];
    
    NSArray<id <IChartDataSet>> *dataSets = @[set];
    
    BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
    [self styleData:data];
    data.valueTextColor = UIColor.whiteColor;
    
    _chartView.data = data;
    
    [_chartView animateWithYAxisDuration:1.4 easingOption:ChartEasingOptionEaseInOutQuart];
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
