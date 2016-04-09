//
//  RealmWikiExampleChartViewController.m
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/01/2016.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "RealmWikiExampleChartViewController.h"
#import "ChartsDemo-Swift.h"
#import <Realm/Realm.h>
#import "Score.h"

@interface RealmWikiExampleChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet LineChartView *lineChartView;
@property (nonatomic, strong) IBOutlet BarChartView *barChartView;

@end

@implementation RealmWikiExampleChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Realm.io Wiki Example";
    
    _lineChartView.delegate = self;
    _barChartView.delegate = self;
    
    [self setupBarLineChartView:_lineChartView];
    [self setupBarLineChartView:_barChartView];
    
    _lineChartView.extraBottomOffset = 5.f;
    _lineChartView.extraRightOffset = 15.f;
    _barChartView.extraBottomOffset = 5.f;
    _barChartView.extraRightOffset = 15.f;
    
    _lineChartView.leftAxis.drawGridLinesEnabled = NO;
    _lineChartView.xAxis.drawGridLinesEnabled = NO;
    _barChartView.leftAxis.drawGridLinesEnabled = NO;
    _barChartView.xAxis.drawGridLinesEnabled = NO;

    // setup realm
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    // clear previous scores that might exist from previous viewing of this VC
    [realm deleteObjects:Score.allObjects];
    
    // write some demo-data into the realm.io database
    Score *score1 = [[Score alloc] initWithTotalScore:100.f scoreNr:0 playerName:@"Peter"];
    [realm addObject:score1];
    
    Score *score2 = [[Score alloc] initWithTotalScore:110.f scoreNr:1 playerName:@"Lisa"];
    [realm addObject:score2];
    
    Score *score3 = [[Score alloc] initWithTotalScore:130.f scoreNr:2 playerName:@"Dennis"];
    [realm addObject:score3];
    
    Score *score4 = [[Score alloc] initWithTotalScore:70.f scoreNr:3 playerName:@"Luke"];
    [realm addObject:score4];
    
    Score *score5 = [[Score alloc] initWithTotalScore:80.f scoreNr:4 playerName:@"Sarah"];
    [realm addObject:score5];
    
    // commit changes to realm db
    [realm commitWriteTransaction];
    
    // add data to the chart
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
    
    // Line chart
    RLMResults *results = [Score allObjectsInRealm:realm];
    
    RealmLineDataSet *lineDataSet = [[RealmLineDataSet alloc] initWithResults:results yValueField:@"totalScore" xIndexField:@"scoreNr"];
    lineDataSet.drawCubicEnabled = NO;
    lineDataSet.label = @"Realm LineDataSet";
    lineDataSet.drawCircleHoleEnabled = NO;
    [lineDataSet setColor:[ChartColorTemplates colorFromString:@"#FF5722"]];
    [lineDataSet setCircleColor:[ChartColorTemplates colorFromString:@"#FF5722"]];
    lineDataSet.lineWidth = 1.8f;
    lineDataSet.circleRadius = 3.6f;
    
    NSArray<id <IChartDataSet>> *lineDataSets = @[lineDataSet];
    
    RealmLineData *lineData = [[RealmLineData alloc] initWithResults:results xValueField:@"playerName" dataSets:lineDataSets];
    [self styleData:lineData];
    
    // set data
    _lineChartView.data = lineData;
    [_lineChartView animateWithYAxisDuration:1.4
                                easingOption:ChartEasingOptionEaseInOutQuart];
    
    // Bar chart
    RealmBarDataSet *barDataSet = [[RealmBarDataSet alloc] initWithResults:results yValueField:@"totalScore" xIndexField:@"scoreNr"];
    barDataSet.colors = @[
                          [ChartColorTemplates colorFromString:@"#FF5722"],
                          [ChartColorTemplates colorFromString:@"#03A9F4"],
                          ];
    barDataSet.label = @"Realm BarDataSet";
    
    NSArray<id <IChartDataSet>> *barDataSets = @[barDataSet];
    
    RealmBarData *barData = [[RealmBarData alloc] initWithResults:results xValueField:@"playerName" dataSets:barDataSets];
    [self styleData:barData];
    
    _barChartView.data = barData;
    [_barChartView animateWithYAxisDuration:1.4
                                easingOption:ChartEasingOptionEaseInOutQuart];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    if (chartView == _lineChartView)
    {
        NSLog(@"chartValueSelected in Line Chart");
    }
    else
    {
        NSLog(@"chartValueSelected in Bar Chart");
    }
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    if (chartView == _lineChartView)
    {
        NSLog(@"chartValueNothingSelected in Line Chart");
    }
    else
    {
        NSLog(@"chartValueNothingSelected in Bar Chart");
    }
}

@end
