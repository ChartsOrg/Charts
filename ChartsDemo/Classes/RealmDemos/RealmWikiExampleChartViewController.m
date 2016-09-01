//
//  RealmWikiExampleChartViewController.m
//  ChartsDemo
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

@interface RealmWikiExampleChartViewController () <ChartViewDelegate, IChartAxisValueFormatter>
{
    RLMResults<Score *> *results;
}

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
    _barChartView.extraBottomOffset = 5.f;
    
    _lineChartView.leftAxis.drawGridLinesEnabled = NO;
    _lineChartView.xAxis.drawGridLinesEnabled = NO;
    _lineChartView.xAxis.labelCount = 5;
    _lineChartView.xAxis.granularity = 1.0;
    _barChartView.leftAxis.drawGridLinesEnabled = NO;
    _barChartView.xAxis.drawGridLinesEnabled = NO;
    _barChartView.xAxis.labelCount = 5;
    _barChartView.xAxis.granularity = 1.0;
    
    // setup realm
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    // clear previous scores that might exist from previous viewing of this VC
    [realm deleteObjects:Score.allObjects];
    
    // write some demo-data into the realm.io database
    Score *score1 = [[Score alloc] initWithTotalScore:100.f scoreNr:0.0 playerName:@"Peter"];
    [realm addObject:score1];
    
    Score *score2 = [[Score alloc] initWithTotalScore:110.f scoreNr:1.0 playerName:@"Lisa"];
    [realm addObject:score2];
    
    Score *score3 = [[Score alloc] initWithTotalScore:130.f scoreNr:2.0 playerName:@"Dennis"];
    [realm addObject:score3];
    
    Score *score4 = [[Score alloc] initWithTotalScore:70.f scoreNr:3.0 playerName:@"Luke"];
    [realm addObject:score4];
    
    Score *score5 = [[Score alloc] initWithTotalScore:80.f scoreNr:4.0 playerName:@"Sarah"];
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
    
    results = [Score allObjectsInRealm:realm];
    
    _lineChartView.xAxis.valueFormatter = self;
    _barChartView.xAxis.valueFormatter = self;
    
    // Line chart
    RealmLineDataSet *lineDataSet = [[RealmLineDataSet alloc] initWithResults:results xValueField:@"scoreNr" yValueField:@"totalScore"];
    lineDataSet.drawCubicEnabled = NO;
    lineDataSet.label = @"Result Scores";
    lineDataSet.drawCircleHoleEnabled = NO;
    [lineDataSet setColor:[ChartColorTemplates colorFromString:@"#FF5722"]];
    [lineDataSet setCircleColor:[ChartColorTemplates colorFromString:@"#FF5722"]];
    lineDataSet.lineWidth = 1.8f;
    lineDataSet.circleRadius = 3.6f;
    
    NSArray<id <IChartDataSet>> *lineDataSets = @[lineDataSet];
    
    LineChartData *lineData = [[LineChartData alloc] initWithDataSets:lineDataSets];
    [self styleData:lineData];
    
    // set data
    _lineChartView.data = lineData;
    [_lineChartView animateWithYAxisDuration:1.4
                                easingOption:ChartEasingOptionEaseInOutQuart];
    
    // Bar chart
    RealmBarDataSet *barDataSet = [[RealmBarDataSet alloc] initWithResults:results xValueField:@"scoreNr" yValueField:@"totalScore"];
    barDataSet.colors = @[
                          [ChartColorTemplates colorFromString:@"#FF5722"],
                          [ChartColorTemplates colorFromString:@"#03A9F4"],
                          ];
    barDataSet.label = @"Realm BarDataSet";
    
    NSArray<id <IChartDataSet>> *barDataSets = @[barDataSet];
    
    BarChartData *barData = [[BarChartData alloc] initWithDataSets:barDataSets];
    [self styleData:barData];
    
    _barChartView.data = barData;
    _barChartView.fitBars = YES;
    [_barChartView notifyDataSetChanged];
    [_barChartView animateWithYAxisDuration:1.4
                                easingOption:ChartEasingOptionEaseInOutQuart];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
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

#pragma mark - IAxisValueFormatter

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
    return ((Score *)results[(int)value]).playerName;
}

@end
